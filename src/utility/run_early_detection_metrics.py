# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import argparse
from google.cloud import bigquery

def run_early_detection_metrics(project_id: str):
    """
    Executes the SQL query to calculate early detection metrics.
    """
    client = bigquery.Client(project=project_id)

    # Read the SQL file
    with open("utility/calculate_early_detection_metrics.sql", "r") as f:
        query_template = f.read()

    # Format the query with the project ID
    query = query_template.format(project_id=project_id)

    print("Calculating Early Detection Metrics...")
    try:
        query_job = client.query(query)
        results = list(query_job.result())  # Wait for the job to complete

        if not results:
            print("No metrics found. Ensure there are audit logs and feedback data available.")
            return

        for row in results:
            print(f"False Alarm Rate: {row.false_alarm_rate:.2%}")
            print(f"Total Alerts: {row.total_alerts}")
            if row.avg_lead_time_minutes is not None:
                print(f"Average Lead Time (True Positives): {row.avg_lead_time_minutes:.2f} minutes")
            else:
                print("Average Lead Time: N/A (No feedback or actions recorded for True Positives)")

    except Exception as e:
        print(f"Error calculating metrics: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Calculate metrics for Early Detection Workflow."
    )
    parser.add_argument(
        "--project_id",
        type=str,
        required=True,
        help="The Google Cloud project ID.",
    )
    args = parser.parse_args()

    run_early_detection_metrics(args.project_id)
