# Anomaly Detection Pipeline with Cloud Workflows and BigQuery ML

This project demonstrates an end-to-end time-series anomaly detection pipeline orchestrated by Google Cloud Workflows.

The pipeline leverages BigQuery ML's `ARIMA_PLUS` model to identify anomalies, and a serverless architecture (Cloud Functions, Cloud Workflows) to run the process efficiently.

## Overview

The core of this workflow is a time-series forecasting model built with BigQuery ML's `ARIMA_PLUS`. The model is used to predict future values of a time-series and to identify anomalies by comparing the actual values against the model's prediction interval.

The entire MLOps lifecycle is orchestrated by a Cloud Workflow, which calls a central Cloud Function to execute the various steps of the pipeline. This includes:

- **Data Drift Detection:** (Optional) Comparing statistical properties of new data with the training data to detect drift.
- **View Creation:** Creating a training view that filters out 'NOISE' data based on user feedback.
- **Model Training:** Training a new `ARIMA_PLUS` model on the filtered data.
- **Model Evaluation:** Evaluating the performance of the new model.
- **Champion/Challenger Selection:** Comparing the new model (challenger) with the currently deployed model (champion) and selecting the best one based on performance metrics.
- **Forecasting:** Generating a forecast with the champion model.
- **Storing Forecasts:** Storing the forecast results in a low-latency Memorystore (Redis) instance for serving.
- **Auditing:** Logging all pipeline activities to a BigQuery table for audit and tracking purposes.

## Architecture

The workflow is designed as follows:

- **Cloud Workflows:** Orchestrates the entire MLOps pipeline, defining the sequence of steps in `workflow/workflow.yaml`.
- **Cloud Functions:** A single Python function in `cloud_function/main.py` acts as the central execution engine for the pipeline. It is responsible for running BigQuery jobs, interacting with Memorystore, and handling the champion/challenger logic.
- **BigQuery ML:** The core machine learning platform.
  - The `ARIMA_PLUS` model is trained, evaluated, and used for forecasting.
  - SQL scripts for these operations are located in `cloud_function/sql/`.
- **Memorystore (Redis):** Stores the latest forecast data, which includes the predicted value, upper and lower bounds of the prediction interval, and the confidence level. This is used by downstream applications to detect anomalies in real-time.
- **BigQuery (Data Storage):**
  - Stores the raw time-series data.
  - Stores the trained BQML models.
  - Stores the audit logs of the MLOps pipeline in a dedicated table (`model_ops.audit_log`).

## File Structure

```
.
├── cloud_function/
│   ├── main.py           # Core Python logic for the Cloud Function
│   ├── requirements.txt    # Dependencies
│   └── sql/
│       ├── detect_drift.sql # SQL for data drift detection
│       ├── train.sql       # SQL for model training
│       ├── evaluate.sql    # SQL for model evaluation
│       └── forecast.sql    # SQL for generating forecasts
├── workflow/
│   └── workflow.yaml     # Cloud Workflow definition
└── README.md             # This file
```

## Deployment Steps

**Prerequisites:**

*   A Google Cloud Project with the `gcloud` CLI configured.
*   Enabled APIs:
    *   Cloud Functions API (`cloudfunctions.googleapis.com`)
    *   Cloud Build API (`cloudbuild.googleapis.com`)
    *   Cloud Workflows API (`workflows.googleapis.com`)
    *   BigQuery API (`bigquery.googleapis.com`)
    *   Memorystore for Redis API (`redis.googleapis.com`)
    *   Serverless VPC Access API (`vpcaccess.googleapis.com`)
*   A BigQuery dataset.
*   A Memorystore Redis instance in a VPC network.

### Step 1: Create a Serverless VPC Access Connector

To allow the Cloud Function to connect to your Memorystore Redis instance, you need a Serverless VPC Access connector.

1.  **Enable the Serverless VPC Access API** if you haven't already:
    ```sh
    gcloud services enable vpcaccess.googleapis.com
    ```

2.  **Create a connector**. Replace the placeholders with your own values. The connector must be in the same region as your Cloud Function. The IP range must be a `/28` CIDR range that is not in use in your VPC.
    ```sh
    gcloud compute networks vpc-access connectors create YOUR_CONNECTOR_NAME \
      --region=YOUR_REGION \
      --network=YOUR_VPC_NETWORK \
      --range=YOUR_IP_RANGE
    ```
    *   `YOUR_CONNECTOR_NAME`: A name for your connector (e.g., `redis-connector`).
    *   `YOUR_REGION`: The region for your connector (e.g., `us-central1`).
    *   `YOUR_VPC_NETWORK`: The name of the VPC network your Memorystore instance is in (e.g., `default`).
    *   `YOUR_IP_RANGE`: An unused `/28` IP range in your VPC (e.g., `10.8.0.0`).

### Step 2: Deploy the Cloud Function

1.  Navigate to the `cloud_function` directory:
    ```sh
    cd anomaly-detection-workflow/cloud_function
    ```

2.  Deploy the function, attaching the VPC connector created in the previous step.
    ```sh
    gcloud functions deploy anomaly-detection-workflow \
      --runtime python313 \
      --memory 1GB \
      --trigger-http \
      --no-allow-unauthenticated \
      --entry-point handle_request \
      --vpc-connector=YOUR_CONNECTOR_NAME \
      --region=YOUR_REGION
    ```
    **Note:** Take note of the `https` trigger URL provided after deployment. You will need it for the workflow. For production, you should secure this function and use authenticated invocations, which is now the default with the `--no-allow-unauthenticated` flag.

### Step 3: Deploy the Cloud Workflow

1.  Navigate to the `workflow` directory:
    ```sh
    cd ../workflow
    ```

2.  Deploy the workflow.
    ```sh
    gcloud workflows deploy anomaly-detection-workflow \
      --source=workflow.yaml \
      --location=YOUR_REGION \
      --project=YOUR_PROJECT_ID
    ```

### Step 4: Execute the Workflow

1.  You can execute the workflow from the Google Cloud Console or via the `gcloud` CLI.

2.  To run via `gcloud`, provide the required parameters. **Crucially, `redis_host` must be the private IP address of your Memorystore Redis instance.**
    ```sh
    gcloud workflows run anomaly-detection-workflow \
      --location=YOUR_REGION \
      --project=YOUR_PROJECT_ID \
      --data='{
        "project_id": "YOUR_PROJECT_ID",
        "bq_dataset": "YOUR_BQ_DATASET",
        "bq_table": "YOUR_SOURCE_DATA_TABLE",
        "bq_model_name": "arima_model_for_anomalies",
        "time_column": "your_time_column_name",
        "value_column": "your_value_column_name",
        "cloud_function_url": "YOUR_CLOUD_FUNCTION_TRIGGER_URL",
        "redis_host": "YOUR_REDIS_INSTANCE_PRIVATE_IP",
        "redis_port": "6379",
        "current_time": "OPTIONAL_CURRENT_TIME_FOR_TESTING"
      }'
    ```

    *   `current_time`: (Optional) A timestamp in `YYYY-MM-DD HH:MM:SS` format. If provided, the workflow will use this time instead of the current UTC time, which is useful for testing or backfilling data.

After execution, the workflow will orchestrate the training, evaluation, and forecasting, with the final results stored in your Memorystore instance.
