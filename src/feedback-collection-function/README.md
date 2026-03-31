# Feedback Collection Cloud Function

This Cloud Function acts as a webhook to collect user feedback on anomalies and store it in BigQuery.

## Overview

The function accepts HTTP POST requests with a JSON payload containing details about a feedback entry (e.g., False Positive, False Negative). It validates the input and inserts a row into the `feedbacks.monthly_feedback` BigQuery table.

## Deployment

To deploy this function to Google Cloud Functions securely (recommended):

```bash
gcloud functions deploy feedback-collection-function \
  --runtime python311 \
  --trigger-http \
  --no-allow-unauthenticated \
  --entry-point handle_feedback \
  --project YOUR_PROJECT_ID \
  --set-env-vars PROJECT_ID=YOUR_PROJECT_ID,DATASET_ID=feedbacks,TABLE_NAME=monthly_feedback
```

Replace `YOUR_PROJECT_ID` with your actual Google Cloud project ID.

**Security Note:** The `--no-allow-unauthenticated` flag ensures that only authorized users or service accounts (with `roles/cloudfunctions.invoker`) can invoke this function.

## Usage

To invoke the function, you must provide an identity token.

### 1. Invoking via `gcloud` (for testing):

```bash
gcloud functions call feedback-collection-function \
  --region=YOUR_REGION \
  --data='{"series_id": "anomaly_time_series", "timestamp": "2025-02-15 10:00:00", "label_type": "FP", "reason_category": "NOISE"}'
```

### 2. Invoking via `curl` with an identity token:

First, generate an identity token (requires `gcloud` auth):
```bash
TOKEN=$(gcloud auth print-identity-token)
```

Then, use the token in the `Authorization` header:
```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/feedback-collection-function \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
  "series_id": "anomaly_time_series",
  "timestamp": "2025-02-15 10:00:00",
  "label_type": "FP",
  "reason_category": "NOISE"
}'
```

### Parameters:

-   `series_id` (string): The identifier of the time series.
-   `timestamp` (string): The timestamp of the feedback event in `YYYY-MM-DD HH:MM:SS` format.
-   `label_type` (string): The type of feedback. Must be either `"FP"` (False Positive) or `"FN"` (False Negative).
-   `reason_category` (string): The reason for the feedback. Must be `"EVENT"`, `"MAINTENANCE"`, or `"NOISE"`.

## Response

-   **200 OK**: Feedback recorded successfully.
-   **400 Bad Request**: Invalid input or missing fields.
-   **500 Internal Server Error**: Error inserting into BigQuery.
