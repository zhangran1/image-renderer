# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import argparse
from google.cloud import bigquery
from google.api_core.exceptions import NotFound

def create_monthly_feedback_table(project_id: str, dataset_id: str, table_name: str):
    """
    Creates a BigQuery table named monthly_feedback with specific constraints.

    Args:
        project_id: The Google Cloud project ID.
        dataset_id: The BigQuery dataset ID.
        table_name: The BigQuery table name.
    """
    client = bigquery.Client(project=project_id)
    dataset_ref = f"{project_id}.{dataset_id}"

    # Check if dataset exists, create if not
    try:
        client.get_dataset(dataset_ref)
        print(f"Dataset {dataset_ref} already exists.")
    except NotFound:
        print(f"Dataset {dataset_ref} not found, creating it.")
        dataset = bigquery.Dataset(dataset_ref)
        dataset.location = "US"  # Set the appropriate location
        client.create_dataset(dataset, timeout=30)
        print(f"Created dataset {dataset_ref}")

    table_id = f"{dataset_ref}.{table_name}"

    # Using DDL to create table with DEFAULT values.
    # Note: CHECK constraints are removed as they are not supported in this BigQuery environment.
    query = f"""
    CREATE TABLE IF NOT EXISTS `{table_id}` (
        series_id STRING,
        timestamp TIMESTAMP,
        label_type STRING,
        reason_category STRING,
        feedback_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    )
    """

    try:
        query_job = client.query(query)
        query_job.result()  # Wait for the job to complete
        print(f"Successfully created or confirmed existence of table {table_id}")
    except Exception as e:
        print(f"Error creating table: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create a BigQuery table for monthly feedback."
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

    create_monthly_feedback_table(args.project_id, args.dataset_id, args.table_name)
