# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import functions_framework
import json
import os
from google.cloud import bigquery
from google.cloud import aiplatform
import redis
import pandas as pd
from datetime import datetime, timezone
from dateutil.relativedelta import relativedelta

DEFAULT_HORIZON = 25


def _get_query(query_name: str, **kwargs) -> str:
    """
    Reads a SQL file from the 'sql' directory and formats it with parameters.
    """
    with open(f"sql/{query_name}.sql", "r") as f:
        query_template = f.read()
    return query_template.format(**kwargs)

def _log_model_creation_to_bq(client, params, start_time, end_time):
    """Inserts a record into the BigQuery audit log table."""
    table_id = "model_ops.audit_log"

    log_params = params.copy()
    log_params['start_time'] = start_time.isoformat()
    log_params['end_time'] = end_time.isoformat()
    
    log_entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "workflow_name": "anomaly-detection",
        "action": "train",
        "project_id": params.get('project_id'),
        "dataset_id": params.get('bq_dataset'),
        "model_name": params.get('bq_model_name'),
        "source_table": f"{params.get('project_id')}.{params.get('bq_dataset')}.{params.get('bq_table')}",
        "parameters": json.dumps(log_params)
    }

    errors = client.insert_rows_json(table_id, [log_entry])
    if errors:
        print(f"Error inserting audit log: {errors}")
    else:
        print(f"Successfully inserted audit log for model {params.get('bq_model_name')}")

@functions_framework.http
def handle_request(request):
    """
    HTTP Cloud Function to orchestrate BQML and Redis operations.
    The request body must be a JSON object with an 'action' key.
    """
    request_json = request.get_json(silent=True)
    if not request_json or 'action' not in request_json:
        return 'Invalid request: Missing JSON body or "action" key.', 400

    action = request_json.get('action')
    print(f"Received action: {action}")

    try:
        if action == 'train':
            return train_model(request_json)
        elif action == 'evaluate':
            return evaluate_model(request_json)
        elif action == 'forecast_and_store':
            return forecast_and_store(request_json)
        elif action == 'get_latest_model_metrics':
            return get_latest_model_metrics(request_json)
        elif action == 'log_deployment':
            return log_deployment(request_json)
        elif action == 'select_champion':
            return select_champion(request_json)
        else:
            return f"Unknown action: {action}", 400
    except Exception as e:
        print(f"Error processing action '{action}': {e}")
        return str(e), 500

def _set_new_champion(new_model_name, vertex_ai_model_id, project_id, location):
    """Sets the new model as the default champion and returns the response."""
    print(f"Setting new model {new_model_name} as champion.")
    try:
        version_alias = new_model_name.split('_')[-1]
        parent_model_name = f"projects/{project_id}/locations/{location}/models/{vertex_ai_model_id}"
        model_version = aiplatform.Model(f"{parent_model_name}@{version_alias}")

        model_registry = aiplatform.ModelRegistry(model=vertex_ai_model_id)
        model_registry.add_version_aliases(new_aliases=["default"], version=model_version.version_id)
        print(f"Set new model version {new_model_name} as default for model {vertex_ai_model_id}")
    except Exception as e:
        print(f"Error setting new champion: {e}")

    return json.dumps({
        "status": "success",
        "champion_model_name": new_model_name,
        "champion_model_source": "new",
        "horizon": DEFAULT_HORIZON
    }), 200

def _calculate_deployed_model_horizon(project_id, deployed_model_name, current_time_iso=None):
    """Calculates the horizon of a deployed model."""
    client = bigquery.Client(project=project_id)
    log_table = f"{project_id}.model_ops.audit_log"
    query = f"""
        SELECT parameters
        FROM `{log_table}`
        WHERE workflow_name = 'anomaly-detection'
          AND action = 'train'
          AND model_name = '{deployed_model_name}'
        ORDER BY timestamp DESC
        LIMIT 1
    """
    try:
        query_job = client.query(query)
        rows = list(query_job.result())

        if rows:
            train_params = json.loads(rows[0].parameters)
            train_end_time_str = train_params.get('end_time')

            if train_end_time_str:
                train_end_time = datetime.fromisoformat(train_end_time_str)

                if current_time_iso:
                    current_time = datetime.fromisoformat(current_time_iso)
                else:
                    current_time = datetime.now(timezone.utc)

                time_diff_hours = (current_time - train_end_time).total_seconds() / 3600
                return int(time_diff_hours)
    except Exception as e:
        print(f"Error calculating deployed model horizon: {e}")
    
    return None

def select_champion(params):
    """
    Selects the champion model based on metrics and horizon constraints.
    """
    new_model_metrics = params['new_model_metrics']
    deployed_model_metrics = params['deployed_model_metrics']
    new_model_name = params['new_model_name']
    vertex_ai_model_id = params['vertex_ai_model_id']
    project_id = params['project_id']
    location = params['location']

    aiplatform.init(project=project_id, location=location)

    # Case 1: No deployed model exists
    if not deployed_model_metrics.get('model_name'):
        print("No deployed model found. New model is champion.")
        return _set_new_champion(new_model_name, vertex_ai_model_id, project_id, location)

    deployed_model_name = deployed_model_metrics['model_name']
    
    deployed_model_horizon = _calculate_deployed_model_horizon(
        project_id, deployed_model_name, params.get("current_time")
    )

    if deployed_model_horizon is None:
        print("Could not determine deployed model horizon, defaulting to new model.")
        return _set_new_champion(new_model_name, vertex_ai_model_id, project_id, location)

    # Case 2: Deployed model horizon exceeds 10,000
    if deployed_model_horizon > 10000:
        print(f"Deployed model horizon ({deployed_model_horizon}) exceeds 10,000. New model is champion.")
        return _set_new_champion(new_model_name, vertex_ai_model_id, project_id, location)

    # Case 3: Compare metrics
    if new_model_metrics.get('mape', float('inf')) < deployed_model_metrics.get('mape', float('inf')) and \
       new_model_metrics.get('aic', float('inf')) < deployed_model_metrics.get('aic', float('inf')):
        print("New model has better metrics. New model is champion.")
        return _set_new_champion(new_model_name, vertex_ai_model_id, project_id, location)
    else:
        print("Deployed model has better metrics. Deployed model is champion.")
        return json.dumps({
            "status": "success",
            "champion_model_name": deployed_model_name,
            "champion_model_source": "deployed",
            "horizon": deployed_model_horizon
        }), 200



def _create_training_view(client, params, source_table):
    """Creates a view for training that filters out 'NOISE' from feedback."""
    view_name = f"{params['project_id']}.{params['bq_dataset']}.training_view_{params['bq_table']}"
    feedback_table = f"{params['project_id']}.feedbacks.monthly_feedback"

    query = _get_query(
        "create_training_view",
        view_name=view_name,
        source_table=source_table,
        feedback_table=feedback_table,
        time_column=params['time_column'],
        series_id=params['bq_table']
    )
    
    print(f"Executing view creation query: {query}")
    job = client.query(query)
    job.result()
    print(f"View '{view_name}' created successfully.")
    return view_name

def train_model(params):
    """Trains a BQML ARIMA_PLUS model from an external SQL file."""
    client = bigquery.Client(project=params['project_id'])

    # Generate version and update model name
    vertex_ai_model_id = params['bq_model_name']
    version = "v" + datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S")
    params['bq_model_name'] = f"{params['bq_model_name']}_{version}"
    
    model_name = f"{params['bq_dataset']}.{params['bq_model_name']}"
    source_table = f"{params['project_id']}.{params['bq_dataset']}.{params['bq_table']}"

    # Create the training view
    view_name = _create_training_view(client, params, source_table)

    current_time_str = params.get("current_time")
    if current_time_str:
        current_time = datetime.fromisoformat(current_time_str)
    else:
        current_time = datetime.now(timezone.utc)
    
    end_time = current_time - relativedelta(hours=1)
    start_time = end_time - relativedelta(months=6)

    query = _get_query(
        "train",
        model_name=model_name,
        time_column=params['time_column'],
        value_column=params['value_column'],
        view_name=view_name,
        start_time=start_time.isoformat(),
        end_time=end_time.isoformat(),
        vertex_ai_model_id=vertex_ai_model_id,
        version_alias=version,
    )
    
    print(f"Executing training query: {query}")
    job = client.query(query)
    job.result()  # Wait for the job to complete

    _log_model_creation_to_bq(client, params, start_time, end_time)

    try:
        print(f"Adding labels to model {model_name}")
        project_id = params['project_id']
        location = params.get('location', 'us-central1')
        aiplatform.init(project=project_id, location=location)

        models = aiplatform.Model.list(filter=f'display_name="{vertex_ai_model_id}"')
        if models:
            parent_model = models[0]
            model_version_name = f"{parent_model.resource_name}@{version}"
            model_with_alias = aiplatform.Model(model_name=model_version_name)

            labels = {
                "bqml_project_id": project_id,
                "bqml_dataset_id": params['bq_dataset'],
                "bqml_model_id": params['bq_model_name'],
                "bq_table": params['bq_table'],
                "time_column": params['time_column'],
                "start_time": start_time.isoformat(),
                "end_time": end_time.isoformat()
            }
            model_with_alias.update(labels=labels)
            print(f"Successfully added labels to model {model_name}")
        else:
            print(f"Could not find model with display name {vertex_ai_model_id} to add labels.")

    except Exception as e:
        print(f"An error occurred while adding labels to the model: {e}")

    
    print(f"Model '{model_name}' created successfully.")
    return json.dumps({"status": "success", "bq_model_name": params['bq_model_name']}), 200

def evaluate_model(params):
    """
    Evaluates a BQML model. Can be called in two ways:
    1. By providing BQML parameters directly: `project_id`, `bq_dataset`, `bq_model_name`, `bq_table`, `time_column`.
    2. By providing Vertex AI model info: `project_id`, `location`, `vertex_ai_model_id`, `version_alias` (e.g., "default").
       In this case, it fetches BQML details from the model's labels in Vertex AI Model Registry.
    """
    project_id = params['project_id']
    location = params.get('location', 'us-central1')

    # If vertex_ai_model_id is provided, fetch BQML details from labels
    if 'vertex_ai_model_id' in params:
        aiplatform.init(project=project_id, location=location)
        version_alias = params.get('version_alias', 'default')
        
        try:
            # First, get the parent model to construct the full resource name
            models = aiplatform.Model.list(filter=f'display_name="{params["vertex_ai_model_id"]}"')
            if not models:
                raise ValueError(f"No model found with display name: {params['vertex_ai_model_id']}")
            
            parent_model = models[0]
            model_version_name = f"{parent_model.resource_name}@{version_alias}"
            model_with_alias = aiplatform.Model(model_name=model_version_name)
            
            labels = model_with_alias.labels
            bq_model_name = labels.get("bqml_model_id")
            bq_dataset = labels.get("bqml_dataset_id")
            bq_project_id = labels.get("bqml_project_id", project_id)
            bq_table = labels.get("bq_table")
            time_column = labels.get("time_column")

            if not all([bq_model_name, bq_dataset, bq_project_id, bq_table, time_column]):
                raise ValueError("Missing one or more required BQML labels from the Vertex AI model.")

            # We have what we need, update params for the rest of the function
            params['project_id'] = bq_project_id
            params['bq_dataset'] = bq_dataset
            params['bq_model_name'] = bq_model_name
            params['bq_table'] = bq_table
            params['time_column'] = time_column

        except Exception as e:
            print(f"Error fetching model details from Vertex AI: {e}")
            # Return null metrics instead of failing, to allow workflow to proceed (e.g. treating as no deployed model)
            return json.dumps({"aic": None, "mape": None, "precision": None, "recall": None}), 200

    # The rest of the function proceeds as before
    client = bigquery.Client(project=params['project_id'])
    model_name = f"{params['bq_dataset']}.{params['bq_model_name']}"
    source_table = f"{params['project_id']}.{params['bq_dataset']}.{params['bq_table']}"
    time_column = params['time_column']

    current_time_str = params.get("current_time")
    if current_time_str:
        current_time = datetime.fromisoformat(current_time_str)
    else:
        current_time = datetime.now(timezone.utc)

    eval_start_time = current_time - relativedelta(hours=1)
    
    feedback_table = f"{params['project_id']}.feedbacks.monthly_feedback"
    # Assuming bq_table is the series_id as per previous convention
    series_id = params['bq_table']

    query = _get_query(
        "evaluate_with_feedback",
        model_name=model_name,
        source_table=source_table,
        time_column=time_column,
        eval_start_time=eval_start_time.isoformat(),
        feedback_table=feedback_table,
        series_id=series_id
    )

    print(f"Executing evaluation query: {query}")
    job = client.query(query)
    df = job.to_dataframe()
    result_dict = df.set_index('metric')['value'].to_dict()
    
    # Handle potential NULLs for precision/recall if no feedback exists
    for metric in ['precision', 'recall']:
        if metric not in result_dict or pd.isna(result_dict[metric]):
            result_dict[metric] = None
            
    results = json.dumps(result_dict)

    print(f"Model '{model_name}' evaluated successfully. Metrics: {results}")
    return results, 200

def forecast_and_store(params):
    """Generates a forecast and stores the results in Memorystore."""
    client = bigquery.Client(project=params['project_id'])
    model_name = f"{params['bq_dataset']}.{params['bq_model_name']}"
    horizon = params.get('horizon', DEFAULT_HORIZON) # Default to 25 if not provided (because newly trained model use end time 1 hour before current time)

    # 1. Generate Forecast in BigQuery from external SQL file
    query = _get_query("forecast", model_name=model_name, horizon=horizon)

    print(f"Executing forecast query: {query}")
    forecast_df = client.query(query).to_dataframe()
    
    print("Forecast generated successfully.")

    # 2. Connect to Memorystore (Redis)
    # The following connection requires the Cloud Function to be configured with a
    # Serverless VPC Access connector to reach the private IP of the Memorystore instance.
    # The 'redis_host' parameter must be the private IP of the Redis instance.
    redis_client = redis.Redis(
        host=params['redis_host'],
        port=params['redis_port'],
        decode_responses=True
    )
    
    print(f"Connected to Redis at {params['redis_host']}:{params['redis_port']}.")

    # 3. Store results in Redis
    forecast_json = forecast_df.to_json(orient='records', date_format='iso')
    redis_key = f"forecast:{params['bq_model_name']}"

    # Cleanup old forecasts
    try:
        forecast_keys = redis_client.keys('forecast:*')
        if len(forecast_keys) >= 5:
            forecast_keys.sort()
            # Delete the oldest keys until there are 4 left
            for i in range(len(forecast_keys) - 4):
                print(f"Deleting old forecast key: {forecast_keys[i]}")
                redis_client.delete(forecast_keys[i])
    except Exception as e:
        print(f"Error cleaning up old forecasts: {e}")

    redis_client.set(redis_key, forecast_json)
    
    print(f"Forecast results stored in Redis with key: {redis_key}")
    
    return json.dumps({
        "status": "success",
        "redis_key": redis_key,
        "records_stored": len(forecast_df)
    }), 200

def get_latest_model_metrics(params):
    """
    Finds the latest deployed model from Vertex AI Model Registry using the 'default' alias
    and returns its evaluation metrics.
    """
    project_id = params['project_id']
    location = params.get('location', 'us-central1')
    vertex_ai_model_id = params['bq_model_name']

    try:
        eval_params = {
            "project_id": project_id,
            "location": location,
            "vertex_ai_model_id": vertex_ai_model_id,
            "version_alias": "default",
            "current_time": params.get("current_time")
        }
        metrics_json, status_code = evaluate_model(eval_params)

        if status_code == 200:
            aiplatform.init(project=project_id, location=location)
            models = aiplatform.Model.list(filter=f'display_name="{vertex_ai_model_id}"')
            parent_model = models[0]
            model_version_name = f"{parent_model.resource_name}@default"
            model_with_alias = aiplatform.Model(model_name=model_version_name)
            
            metrics = json.loads(metrics_json)
            metrics["model_name"] = model_with_alias.labels.get("bqml_model_id")
            return json.dumps(metrics), status_code
        else:
            print("Could not evaluate model using BQML labels.")
            return metrics_json, status_code


    except Exception as e:
        # This block catches errors like the 'default' alias not being found,
        # or any other issue during the API calls.
        print(f"Could not retrieve latest model metrics from Vertex AI. This can happen if no model is deployed yet. Error: {e}")
        return json.dumps({"aic": 1e9, "mape": 1e9, "model_name": None}), 200

def log_deployment(params):
    """Inserts a 'deploy' record into the BigQuery audit log table."""
    client = bigquery.Client(project=params['project_id'])
    table_id = "model_ops.audit_log"
    
    log_entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "workflow_name": "anomaly-detection",
        "action": "deploy",
        "project_id": params.get('project_id'),
        "dataset_id": params.get('bq_dataset'),
        "model_name": params.get('bq_model_name'),
        "source_table": f"{params.get('project_id')}.{params.get('bq_dataset')}.{params.get('bq_table')}",
        "parameters": json.dumps(params)
    }

    errors = client.insert_rows_json(table_id, [log_entry])
    if errors:
        print(f"Error inserting deployment log: {errors}")
        # Return 500 to indicate error in workflow
        return json.dumps({"status": "error", "errors": str(errors)}), 500
    else:
        print(f"Successfully inserted deployment log for model {params.get('bq_model_name')}")
        return json.dumps({"status": "success"}), 200
