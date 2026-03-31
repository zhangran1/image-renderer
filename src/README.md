# udk-mlops

MLOps repository for NTT DOCOMO Unyou Data Kiban (UDK) system.

This repository contains various MLOps projects and workflows.

## Cloning the Repository

To clone this repository, you need to authenticate with Google Cloud and configure Git to use `gcloud` as a credential helper. This allows Git to use your Google Cloud credentials to authenticate with Source Repository.

1.  **Login to gcloud:**
    ```bash
    gcloud auth login
    ```

2.  **Configure Git Credential Helper:**
    ```bash
    git config --global credential.helper gcloud.sh
    ```

3.  **Clone the Repository:**
    ```bash
    git clone https://docomo-567794993156-git.asia-east1.sourcemanager.dev/cloud-professional-services/udk-mlops.git
    ```

## Sub-projects

### Anomaly Detection Workflow

The `anomaly-detection-workflow` directory contains a project for an end-to-end time-series anomaly detection pipeline orchestrated by Google Cloud Workflows.

This pipeline leverages BigQuery ML's `ARIMA_PLUS` model to identify anomalies, and a serverless architecture (Cloud Functions, Cloud Workflows) to run the process efficiently.

For more details, see the [anomaly-detection-workflow/README.md](anomaly-detection-workflow/README.md).

### Early Detection Workflow

The `early-detection-workflow` directory contains a project for an MLOps pipeline that uses change point detection to identify a sudden increase in a time series and then uses BigQuery ML's `ARIMA_PLUS` model to forecast future values and send alerts to Slack if a threshold is predicted to be exceeded.

For more details, see the [early-detection-workflow/README.md](early-detection-workflow/README.md).
