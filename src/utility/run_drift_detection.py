# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import argparse
from google.cloud import bigquery

def run_drift_detection(
    project_id: str,
    location: str,
    model_name: str,
    time_column: str,
    value_column: str,
    source_table: str,
    audit_table: str,
    use_audit_log: bool,
):
    """
    Runs the drift detection query in BigQuery.
    Args:
        project_id: The Google Cloud project ID.
        location: The location of the BigQuery dataset.
        model_name: The name of the model to check drift for.
        time_column: The name of the time column in the source table.
        value_column: The name of the value column in the source table.
        source_table: The BigQuery table to check for drift.
        audit_table: The BigQuery table containing audit logs.
        use_audit_log: Whether to use the audit log to get the last training window.
    """
    client = bigquery.Client(project=project_id, location=location)
    start_time = None
    end_time = None
    if use_audit_log:
        # Get the last training window from the audit log
        audit_query = f"""
            SELECT
                JSON_EXTRACT_SCALAR(parameters, '$.start_time') as start_time,
                JSON_EXTRACT_SCALAR(parameters, '$.end_time') as end_time,
                source_table
            FROM `{audit_table}`
            WHERE workflow_name = 'anomaly-detection' AND action = 'train'
            ORDER BY timestamp DESC
            LIMIT 1
        """
        print("Querying audit log to get last training window...")
        query_job = client.query(audit_query)
        results = query_job.result()
        for row in results:
            start_time = row.start_time
            end_time = row.end_time
            source_table = row.source_table
        if not all([start_time, end_time, source_table]):
            raise RuntimeError("Could not retrieve training window from audit log.")
        print(f"Found training window: {start_time} - {end_time} on table {source_table}")
    with open("../anomaly-detection-workflow/cloud_function/sql/detect_drift.sql") as f:
        sql_template = f.read()
    # We remove the DECLARE and SET statements from the SQL file as we will
    # be providing the values directly.
    sql_script = "\n".join(sql_template.splitlines()[8:])
    
    
    job_config = bigquery.QueryJobConfig(
        query_parameters=[
            bigquery.ScalarQueryParameter("model_name", "STRING", model_name),
            bigquery.ScalarQueryParameter("audit_table", "STRING", audit_table),
            bigquery.ScalarQueryParameter("start_time", "STRING", start_time),
            bigquery.ScalarQueryParameter("end_time", "STRING", end_time),
        ]
    )
    
    query = sql_script.replace("{time_column}", time_column)
    query = query.replace("{value_column}", value_column)
    query = query.replace("{source_table}", source_table)
    query = query.replace("{audit_table}", audit_table)
    
    print("\nRunning drift detection query...")
    query_job = client.query(query, job_config=job_config)
    results = query_job.result()
    print("\nDrift detection results:")
    for row in results:
        print(f"  Training Mean: {row.training_mean}")
        print(f"  Training Stddev: {row.training_stddev}")
        print(f"  New Data Mean: {row.new_data_mean}")
        print(f"  New Data Stddev: {row.new_data_stddev}")
        print(f"  Drift Detected: {row.drift_detected}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Run BigQuery drift detection query."
    )
    parser.add_argument(
        "--project_id",
        type=str,
        required=True,
        help="The Google Cloud project ID.",
    )
    parser.add_argument(
        "--location",
        type=str,
        default="US",
        help="The location of the BigQuery dataset (e.g., 'US', 'EU').",
    )
    parser.add_argument(
        "--model_name",
        type=str,
        default="anomaly_detection_model",
        help="The name of the model to check drift for.",
    )
    parser.add_argument(
        "--time_column",
        type=str,
        default="ts",
        help="The name of the time column in the source table.",
    )
    parser.add_argument(
        "--value_column",
        type=str,
        default="value",
        help="The name of the value column in the source table.",
    )
    parser.add_argument(
        "--source_table",
        type=str,
        help="The BigQuery table to check for drift (e.g., 'project.dataset.table'). "
             "Required if --use_audit_log is not specified.",
    )
    parser.add_argument(
        "--audit_table",
        type=str,
        default="model_ops.audit_log",
        help="The BigQuery table containing audit logs.",
    )
    parser.add_argument(
        "--use_audit_log",
        action="store_true",
        help="Use the audit log to get the last training window. "
             "If set, --source_table, --start_time and --end_time are ignored.",
    )

    args = parser.parse_args()

    if not args.use_audit_log and not args.source_table:
        parser.error("--source_table is required when --use_audit_log is not set.")

    run_drift_detection(
        project_id=args.project_id,
        location=args.location,
        model_name=args.model_name,
        time_column=args.time_column,
        value_column=args.value_column,
        source_table=args.source_table,
        audit_table=args.audit_table,
        use_audit_log=args.use_audit_log,
    )
