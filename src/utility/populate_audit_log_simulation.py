# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import argparse
import json
from google.cloud import bigquery
from datetime import datetime, timezone

def populate_audit_log_simulation(project_id: str):
    """
    Populates the model_ops.audit_log table with simulated alerts for early detection.
    """
    client = bigquery.Client(project=project_id)
    table_id = f"{project_id}.model_ops.audit_log"

    # Simulate alerts corresponding to our feedback scenarios
    rows_to_insert = [
        # 1. False Alarm (FP) Alert
        # Alert generated on Feb 10 (matching the FP feedback)
        {
            "timestamp": "2025-02-10 10:00:00",
            "workflow_name": "early-detection",
            "action": "forecast_and_publish",
            "project_id": project_id,
            "dataset_id": "simulation_data",
            "model_name": "early_detection_model_v1",
            "source_table": f"{project_id}.simulation_data.change_point_time_series",
            "parameters": json.dumps({
                "project_id": project_id,
                "bq_dataset": "simulation_data",
                "bq_table": "change_point_time_series",
                "bq_model_name": "early_detection_model_v1",
                "threshold": 90,
                "pubsub_topic": "early-detection-alerts",
                "status": "alert published",
                "predicted_exceed_time": "2025-02-12 10:00:00" # Predicted to cross in 2 days
            })
        },

        # 2. True Positive (TP) Alert
        # Alert generated on Mar 05 (matching the TP feedback action on Mar 10)
        {
            "timestamp": "2025-03-05 08:00:00",
            "workflow_name": "early-detection",
            "action": "forecast_and_publish",
            "project_id": project_id,
            "dataset_id": "simulation_data",
            "model_name": "early_detection_model_v2",
            "source_table": f"{project_id}.simulation_data.change_point_time_series",
            "parameters": json.dumps({
                "project_id": project_id,
                "bq_dataset": "simulation_data",
                "bq_table": "change_point_time_series",
                "bq_model_name": "early_detection_model_v2",
                "threshold": 90,
                "pubsub_topic": "early-detection-alerts",
                "status": "alert published",
                "predicted_exceed_time": "2025-03-08 08:00:00" # Predicted to cross in 3 days
            })
        }
    ]

    errors = client.insert_rows_json(table_id, rows_to_insert)
    if errors == []:
        print(f"Successfully inserted {len(rows_to_insert)} simulated alerts into {table_id}.")
    else:
        print(f"Encountered errors while inserting rows: {errors}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Populate audit log with simulated alerts."
    )
    parser.add_argument(
        "--project_id",
        type=str,
        required=True,
        help="The Google Cloud project ID.",
    )
    args = parser.parse_args()

    populate_audit_log_simulation(args.project_id)
