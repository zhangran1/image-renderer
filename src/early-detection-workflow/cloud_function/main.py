# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import os
import json
import pandas as pd
import numpy as np
import ruptures as rpt
from kneed import KneeLocator
from google.cloud import bigquery
from google.cloud import pubsub_v1
from datetime import datetime, timezone
from dateutil.relativedelta import relativedelta

# Initialize clients
bq_client = bigquery.Client()
publisher = pubsub_v1.PublisherClient()

# Constants
DEFAULT_PENALTY = 10
DEFAULT_WINDOW_SIZE = 10

def _get_query(query_name: str, **kwargs) -> str:
    """
    Reads a SQL file from the 'sql' directory and formats it with parameters.
    """
    with open(f"sql/{query_name}.sql", "r") as f:
        query_template = f.read()
    return query_template.format(**kwargs)

def _create_training_view(params):
    """Creates a view for training that filters out 'NOISE' and 'FP' from feedback."""
    view_name = f"{params['project_id']}.{params['bq_dataset']}.training_view_{params['bq_table']}"
    feedback_table = f"{params['project_id']}.feedbacks.monthly_feedback"
    source_table = f"{params['project_id']}.{params['bq_dataset']}.{params['bq_table']}"

    query = _get_query(
        "create_training_view",
        view_name=view_name,
        source_table=source_table,
        feedback_table=feedback_table,
        time_column=params['time_column'],
        series_id=params['bq_table']
    )
    
    print(f"Executing view creation query: {query}")
    job = bq_client.query(query)
    job.result()
    print(f"View '{view_name}' created successfully.")
    return view_name

def _log_audit_log(action, params):
    """Inserts a record into the BigQuery audit log table."""
    table_id = "model_ops.audit_log"

    source_table = "not-applicable"
    if params.get('bq_table'):
        source_table = f"{params.get('project_id')}.{params.get('bq_dataset')}.{params.get('bq_table')}"

    log_entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "workflow_name": "early-detection",
        "action": action,
        "project_id": params.get('project_id'),
        "dataset_id": params.get('bq_dataset'),
        "model_name": params.get('bq_model_name', "not-applicable"),
        "source_table": source_table,
        "parameters": json.dumps(params)
    }

    errors = bq_client.insert_rows_json(table_id, [log_entry])
    if errors:
        print(f"Error inserting audit log: {errors}")
    else:
        print(f"Successfully inserted audit log for action {action}")

def _is_trend_increasing(points, last_change_point_index, window_size=DEFAULT_WINDOW_SIZE):
    """
    Checks if the trend is increasing after the last change point by comparing
    the average of a window of points before and after the change point.
    """
    start_index_before = max(0, last_change_point_index - window_size)
    end_index_after = min(len(points), last_change_point_index + window_size + 1)

    points_before = points[start_index_before:last_change_point_index]
    points_after = points[last_change_point_index + 1:end_index_after]

    if points_before.size > 0 and points_after.size > 0:
        avg_before = np.mean(points_before)
        avg_after = np.mean(points_after)
        return bool(avg_after > avg_before)
    
    return False

def handle_request(request):
    """
    HTTP Cloud Function entry point.
    """
    request_json = request.get_json(silent=True)
    
    if not request_json:
        return ("No JSON body provided.", 400)

    action = request_json.get("action")
    
    if not action:
        return ("No action specified.", 400)

    if action == "detect_change_points":
        return detect_change_points(request_json)
    elif action == "train_model":
        return train_model(request_json)
    elif action == "forecast_and_publish":
        return forecast_and_publish(request_json)
    else:
        return (f"Unknown action: {action}", 400)

def detect_change_points(request_json):
    """
    Detects change points in a time series using PELT.
    """
    project_id = request_json.get("project_id")
    bq_dataset = request_json.get("bq_dataset")
    bq_table = request_json.get("bq_table")
    time_column = request_json.get("time_column")
    value_column = request_json.get("value_column")
    current_time_str = request_json.get("current_time")

    if not all([project_id, bq_dataset, bq_table, time_column, value_column]):
        return ("Missing required parameters for detect_change_points", 400)

    if current_time_str:
        end_time = datetime.fromisoformat(current_time_str)
    else:
        end_time = datetime.now(timezone.utc)
    
    start_time = end_time - relativedelta(months=6)

    # Create the training view
    params = {
        'project_id': project_id,
        'bq_dataset': bq_dataset,
        'bq_table': bq_table,
        'time_column': time_column
    }
    view_name = _create_training_view(params)

    query = _get_query(
        "get_time_series",
        view_name=view_name,
        time_column=time_column,
        value_column=value_column,
        start_time=start_time.isoformat(),
        end_time=end_time.isoformat()
    )
    
    try:
        df = bq_client.query(query).to_dataframe()
    except Exception as e:
        return (f"Error querying BigQuery: {e}", 500)

    if df.empty:
        return ("No data found in BigQuery table for the last 6 months.", 404)

    points = df[value_column].values
    
    algo = rpt.Pelt(model="rbf").fit(points)
    
    # The penalty value is now configurable via the request, with a default of DEFAULT_PENALTY
    # If "auto", use elbow method to find optimal pen
    pen = request_json.get("pen", DEFAULT_PENALTY)
    
    if pen == "auto":
        # Use elbow method on (penalty vs n_bkpts) to find a stable penalty
        pen_values = np.linspace(1, 100, 20)
        n_bkpts_list = []
        for p in pen_values:
            res = algo.predict(pen=p)
            n_bkpts_list.append(len(res) - 1)
        
        if len(set(n_bkpts_list)) > 2:
            try:
                # curve='convex', direction='decreasing' finds the point where the number of breakpoints stabilizes
                kn = KneeLocator(pen_values, n_bkpts_list, curve='convex', direction='decreasing')
                pen = kn.knee or DEFAULT_PENALTY
            except Exception as e:
                print(f"Error finding knee: {e}")
                pen = DEFAULT_PENALTY
        else:
            pen = DEFAULT_PENALTY

    result = algo.predict(pen=pen)

    last_change_point_timestamp = None
    is_increasing = False  # Default to False
    if len(result) > 1:
        # result[-1] is the end of the series, so the last change point is at result[-2]
        last_change_point_index = result[-2]
        last_change_point_timestamp = df[time_column].iloc[last_change_point_index].isoformat()

        # Check if the trend is increasing after the last change point
        if last_change_point_index > 0:
            is_increasing = _is_trend_increasing(points, last_change_point_index)
    
    _log_audit_log("detect_change_points", request_json)

    return ({"last_change_point_timestamp": last_change_point_timestamp, "is_increasing": is_increasing, "end_time": end_time.isoformat()}, 200)

def train_model(request_json):
    """
    Trains a BQML ARIMA_PLUS model.
    """
    project_id = request_json.get("project_id")
    bq_dataset = request_json.get("bq_dataset")
    bq_model_name = request_json.get("bq_model_name")
    time_column = request_json.get("time_column")
    value_column = request_json.get("value_column")
    bq_table = request_json.get("bq_table")
    start_time = request_json.get("start_time")
    end_time = request_json.get("end_time")

    if not all([project_id, bq_dataset, bq_model_name, time_column, value_column, start_time, end_time]):
        return ("Missing required parameters for train_model", 400)
    
    # Create the training view
    params = {
        'project_id': project_id,
        'bq_dataset': bq_dataset,
        'bq_table': bq_table,
        'time_column': time_column
    }
    view_name = _create_training_view(params)

    # Read the training SQL and format it
    sql = _get_query(
        "train",
        project_id=project_id,
        bq_dataset=bq_dataset,
        bq_model_name=bq_model_name,
        time_column=time_column,
        value_column=value_column,
        view_name=view_name,
        start_time=start_time,
        end_time=end_time
    )

    try:
        bq_client.query(sql).result()
        _log_audit_log("train", request_json)
    except Exception as e:
        return (f"Error training model: {e}", 500)
        
    return ("Model training started.", 200)

def forecast_and_publish(request_json):
    """
    Generates a forecast and publishes a message to Pub/Sub if a threshold is exceeded.
    """
    project_id = request_json.get("project_id")
    bq_dataset = request_json.get("bq_dataset")
    bq_model_name = request_json.get("bq_model_name")
    threshold = request_json.get("threshold")
    pubsub_topic = request_json.get("pubsub_topic")
    
    if not all([project_id, bq_dataset, bq_model_name, threshold, pubsub_topic]):
        return ("Missing required parameters for forecast_and_publish", 400)
        
    # Read the forecast SQL
    sql = _get_query(
        "forecast",
        project_id=project_id,
        bq_dataset=bq_dataset,
        bq_model_name=bq_model_name
    )
    
    try:
        forecast_df = bq_client.query(sql).to_dataframe()
    except Exception as e:
        return (f"Error running forecast: {e}", 500)

    # Check if any forecasted value exceeds the threshold
    exceeded = forecast_df[forecast_df["forecast_value"] > threshold]
    
    first_exceed_time = None
    status = "within threshold"

    if not exceeded.empty:
        # Find the first time the threshold is exceeded
        first_exceed_time = exceeded.iloc[0]["forecast_timestamp"]
        message = f":warning: Forecast predicts values will exceed threshold {threshold} at {first_exceed_time}."
        
        try:
            topic_path = publisher.topic_path(project_id, pubsub_topic)
            message_json = json.dumps({"message": message})
            future = publisher.publish(topic_path, data=message_json.encode("utf-8"))
            future.result()
            status = "alert published"
        except Exception as e:
            return (f"Error publishing to Pub/Sub: {e}", 500)

    # Log the result to the audit log
    log_params = request_json.copy()
    if first_exceed_time:
        log_params['predicted_exceed_time'] = first_exceed_time.isoformat()
    log_params['status'] = status
    
    _log_audit_log("forecast_and_publish", log_params)
    
    first_exceed_time_iso = first_exceed_time.isoformat() if first_exceed_time else None
    
    return ({"status": status, "first_exceed_time": first_exceed_time_iso}, 200)
        