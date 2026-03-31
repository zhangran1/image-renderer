# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import argparse
from google.cloud import bigquery
from datetime import datetime, timezone

def populate_early_detection_feedback(project_id: str, dataset_id: str, table_name: str):
    """
    Populates the monthly_feedback table with sample data for early detection workflow.
    """
    client = bigquery.Client(project=project_id)
    table_id = f"{project_id}.{dataset_id}.{table_name}"

    # Sample feedback data for 'change_point_time_series'
    # Based on simulation data in generate_simulation_data.sql
    rows_to_insert = [
        # 1. False Positive (FP): The short spike around Feb 10
        {
            "series_id": "change_point_time_series",
            "timestamp": "2025-02-10 10:00:00", 
            "label_type": "FP",
            "reason_category": "NOISE",
            "feedback_at": "2025-02-10 12:30:00" # Feedback given shortly after
        },
        
        # 2. True Positive (TP) - Action Taken:
        # The trend started Mar 01. The alert would happen sometime after.
        # The user intervened (Restart) on Mar 10.
        # We log this to calculate "Lead Time" (Alert Time vs Action Time).
        {
            "series_id": "change_point_time_series",
            "timestamp": "2025-03-05 08:00:00", # Assuming alert happened here
            "label_type": "CONFIRMED", # Not FP
            "reason_category": "EVENT",
            "feedback_at": "2025-03-10 12:00:00" # Time of intervention
        },

        # 3. False Negative (FN): The rapid spike on Mar 20
        # The model missed it because it was too fast or unexpected.
        {
            "series_id": "change_point_time_series",
            "timestamp": "2025-03-20 15:00:00",
            "label_type": "FN",
            "reason_category": "EVENT",
            "feedback_at": "2025-03-20 17:00:00" # Noticed after the fact
        }
    ]

    errors = client.insert_rows_json(table_id, rows_to_insert)
    if errors == []:
        print(f"Successfully inserted {len(rows_to_insert)} rows for early detection into {table_id}.")
    else:
        print(f"Encountered errors while inserting rows: {errors}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Populate the monthly_feedback table with sample data for early detection."
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

    populate_early_detection_feedback(args.project_id, args.dataset_id, args.table_name)
