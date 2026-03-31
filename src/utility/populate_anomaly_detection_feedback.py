# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import argparse
from google.cloud import bigquery
from datetime import datetime, timezone

def populate_feedback_table(project_id: str, dataset_id: str, table_name: str):
    """
    Populates the monthly_feedback table with sample data.
    """
    client = bigquery.Client(project=project_id)
    table_id = f"{project_id}.{dataset_id}.{table_name}"

    # Sample feedback data
    # Timestamps correspond to the simulation data in generate_simulation_data.sql
    rows_to_insert = [
        # Feedback for anomaly_time_series
        # 1. A False Negative (FN): The model missed a real anomaly (simulated)
        {
            "series_id": "anomaly_time_series",
            "timestamp": "2025-02-16 14:00:00", # Arbitrary time
            "label_type": "FN",
            "reason_category": "EVENT",
            "feedback_at": datetime.now(timezone.utc).isoformat()
        },
        # 2. A 'NOISE' entry: The user marked this as noise (to be filtered out by training view)
        {
            "series_id": "anomaly_time_series",
            "timestamp": "2025-02-10 09:00:00",
            "label_type": "FP", # It was flagged but it's just noise
            "reason_category": "NOISE",
            "feedback_at": datetime.now(timezone.utc).isoformat()
        },
        
        # Feedback for normal_time_series
        # 3. A False Positive (FP): The model flagged this as anomaly but it's normal
        {
            "series_id": "normal_time_series",
            "timestamp": "2025-01-20 18:00:00",
            "label_type": "FP",
            "reason_category": "MAINTENANCE", # Maybe maintenance caused a spike that is not an anomaly of interest
            "feedback_at": datetime.now(timezone.utc).isoformat()
        }
    ]

    errors = client.insert_rows_json(table_id, rows_to_insert)
    if errors == []:
        print(f"Successfully inserted {len(rows_to_insert)} rows into {table_id}.")
    else:
        print(f"Encountered errors while inserting rows: {errors}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Populate the monthly_feedback table with sample data."
    )
    parser.add_argument(
        "--project_id",
        type=str,
        required=True,
        help="The Google Cloud project ID.",
    )
    parser.add_argument(
        "--dataset_id",
        type=str,
        default="feedbacks",
        help="The BigQuery dataset ID.",
    )
    parser.add_argument(
        "--table_name",
        type=str,
        default="monthly_feedback",
        help="The BigQuery table name.",
    )
    args = parser.parse_args()

    populate_feedback_table(args.project_id, args.dataset_id, args.table_name)
