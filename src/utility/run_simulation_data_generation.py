# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

# run_simulation_data_generation.py

import argparse
from google.cloud import bigquery
from google.cloud.exceptions import NotFound

# This script requires the google-cloud-bigquery library.
# Install it with: pip install google-cloud-bigquery

def main(project_id, dataset_id):
    """
    Reads the generate_simulation_data.sql script, replaces placeholders,
    and executes it in BigQuery.
    """
    
    print("Reading the SQL script...")
    with open("generate_simulation_data.sql", "r") as f:
        sql_content = f.read()

    print(f"Replacing placeholders with project_id='{project_id}' and dataset_id='{dataset_id}'...")
    sql_content = sql_content.replace("your_project_id", project_id)
    sql_content = sql_content.replace("your_dataset_id", dataset_id)

    print("Initializing BigQuery client...")
    client = bigquery.Client(project=project_id)

    dataset_ref = client.dataset(dataset_id)
    try:
        client.get_dataset(dataset_ref)
        print(f"Dataset '{dataset_id}' already exists.")
    except NotFound:
        print(f"Dataset '{dataset_id}' not found, creating it...")
        dataset = bigquery.Dataset(dataset_ref)
        dataset.location = "US"
        client.create_dataset(dataset)
        print(f"Successfully created dataset '{dataset_id}'.")

    print("Executing the SQL script in BigQuery...")
    try:
        query_job = client.query(sql_content)
        query_job.result()  # Wait for the job to complete
        print("Successfully generated simulation data in BigQuery.")
        print("The following tables have been created:")
        print(f"- {project_id}.{dataset_id}.normal_time_series")
        print(f"- {project_id}.{dataset_id}.anomaly_time_series")
        print(f"- {project_id}.{dataset_id}.change_point_time_series")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate simulation data in BigQuery by executing a SQL script."
    )
    parser.add_argument(
        "--project_id",
        type=str,
        required=True,
        help="Your Google Cloud project ID."
    )
    parser.add_argument(
        "--dataset_id",
        type=str,
        required=True,
        help="The BigQuery dataset ID where the tables will be created."
    )
    args = parser.parse_args()
    
    main(args.project_id, args.dataset_id)