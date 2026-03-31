# Early Detection Workflow with Change Point Detection and Forecasting

This project demonstrates an MLOps pipeline for early detection of significant changes in time-series data. It uses change point detection to identify a sudden increase and then uses BigQuery ML's `ARIMA_PLUS` model to forecast future values and publishes a message to a Pub/Sub topic if a threshold is predicted to be exceeded.

The pipeline includes a **feedback-aware** mechanism that filters out noisy data points or false alarms based on user feedback stored in a central `monthly_feedback` table.

## Architecture

The workflow is orchestrated by Google Cloud Workflows and involves a Cloud Function and BigQuery ML.

1.  **Cloud Workflow**: The central orchestrator, defined in `workflow.yaml`. It is triggered manually or on a schedule.
2.  **Cloud Function**: A Python function in `cloud_function/main.py` that handles the logic for:
    *   **Creating a Training View**: Dynamically generates a BigQuery view that filters out data points marked as `NOISE` or `FP` in the feedback table.
    *   **Detecting Change Points**: Identifies significant shifts in a time series using the `ruptures` library (PELT algorithm), operating on the cleaned data view.
    *   **Training a Model**: Trains a BigQuery ML `ARIMA_PLUS` model on the cleaned data.
    *   **Forecasting & Alerting**: Generates a forecast and publishes to Pub/Sub if a threshold is predicted to be exceeded.
3.  **BigQuery ML**: 
    *   An `ARIMA_PLUS` model is trained if an increasing trend is detected.
    *   The model is used to forecast future values.
4.  **Pub/Sub**: Alert messages are published to a specified Pub/Sub topic.

## File Structure

```
.
├── cloud_function/
│   ├── main.py           # Python source for the Cloud Function
│   ├── requirements.txt    # Dependencies for the Cloud Function
│   └── sql/
│       ├── create_training_view.sql # SQL to create the cleaned data view
│       ├── get_time_series.sql      # SQL to retrieve data for change point detection
│       ├── train.sql       # SQL query to train the BQML model
│       └── forecast.sql    # SQL query to generate forecasts
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
    *   Pub/Sub API (`pubsub.googleapis.com`)
*   A BigQuery dataset with a table containing time-series data.
*   A Pub/Sub topic to receive alerts.
*   A `feedbacks.monthly_feedback` table (see utility folder).

### Step 1: Deploy the Cloud Function

1.  Navigate to the `early-detection-workflow/cloud_function` directory:
    ```sh
    cd early-detection-workflow/cloud_function
    ```

2.  Deploy the function.

    ```sh
    gcloud functions deploy early-detection-workflow \
      --runtime python313 \
      --memory 1GB \
      --trigger-http \
      --no-allow-unauthenticated \
      --entry-point handle_request
    ```

### Step 2: Deploy the Cloud Workflow

1.  Navigate to the `workflow` directory:
    ```sh
    cd ../workflow
    ```

2.  Deploy the workflow.

    ```sh
    gcloud workflows deploy early-detection-workflow \
      --source=workflow.yaml \
      --location=YOUR_REGION \
      --project=YOUR_PROJECT_ID
    ```

### Step 3: Execute the Workflow

1.  You can execute the workflow from the Google Cloud Console or via the `gcloud` CLI.

2.  To run via `gcloud`, provide the required parameters:

    ```sh
    gcloud workflows run early-detection-workflow \
      --location=YOUR_REGION \
      --project=YOUR_PROJECT_ID \
      --data='{
        "project_id": "YOUR_PROJECT_ID",
        "bq_dataset": "YOUR_BQ_DATASET",
        "bq_table": "YOUR_SOURCE_DATA_TABLE",
        "time_column": "your_time_column_name",
        "value_column": "your_value_column_name",
        "bq_model_name": "early_detection_arima_model",
        "threshold": 1000,
        "pubsub_topic": "your-pubsub-topic-name",
        "cloud_function_url": "YOUR_CLOUD_FUNCTION_TRIGGER_URL",
        "current_time": "OPTIONAL_CURRENT_TIME_FOR_TESTING",
        "pen": 10
      }'
    ```

## Assumptions and Improvements

*   **Feedback Integration**: The workflow now automatically excludes data points marked as `NOISE` or `FP` from both the change point detection and the model training phases.
*   The penalty value in the PELT algorithm in `main.py` (`pen=10`) may need tuning for your specific dataset.
