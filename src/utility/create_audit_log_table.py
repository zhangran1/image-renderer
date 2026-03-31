# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import argparse
from google.cloud import bigquery
from google.api_core.exceptions import NotFound

def create_audit_log_table(project_id: str, table_id: str):
    """
    Creates a BigQuery table for audit logging.

    Args:
        project_id: The Google Cloud project ID.
        table_id: The BigQuery table ID in the format 'dataset.table'.
    """
    client = bigquery.Client(project=project_id)

    # Extract dataset ID from table_id
    dataset_id = table_id.split('.')[0]
    full_dataset_id = f"{project_id}.{dataset_id}"

    # Check if dataset exists, create if not
    try:
        client.get_dataset(full_dataset_id)
        print(f"Dataset {full_dataset_id} already exists.")
    except NotFound:
        print(f"Dataset {full_dataset_id} not found, creating it.")
        dataset = bigquery.Dataset(full_dataset_id)
        dataset.location = "US"  # Set the appropriate location
        client.create_dataset(dataset, timeout=30)
        print(f"Created dataset {full_dataset_id}")

    schema = [
        bigquery.SchemaField("timestamp", "TIMESTAMP", mode="REQUIRED"),
        bigquery.SchemaField("workflow_name", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("action", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("project_id", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("dataset_id", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("model_name", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("source_table", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("parameters", "STRING", mode="REQUIRED"),
    ]

    table = bigquery.Table(f"{project_id}.{table_id}", schema=schema)
    table.time_partitioning = bigquery.TimePartitioning(
        type_=bigquery.TimePartitioningType.DAY,
        field="timestamp",
    )
    
    table.description = "Audit log for model operations in anomaly and early detection workflows."

    try:
        table = client.create_table(table)
        print(f"Created table {table.project}.{table.dataset_id}.{table.table_id}")
    except Exception as e:
        print(f"Error creating table: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create a BigQuery table for audit logging."
    )
    parser.add_argument(
        "--project_id",
        type=str,
        required=True,
        help="The Google Cloud project ID.",
    )
    parser.add_argument(
        "--table_id",
        type=str,
        default="model_ops.audit_log",
        help="The BigQuery table ID in the format 'dataset.table'.",
    )
    args = parser.parse_args()

    create_audit_log_table(args.project_id, args.table_id)
