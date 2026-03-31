# udk-mlops

MLOps repository for NTT DOCOMO Unyou Data Kiban (UDK) system.

This repository contains various MLOps projects and workflows designed to run on Google Cloud Platform, leveraging serverless and managed services for efficient and scalable machine learning operations.

## Tech Stack

- **Orchestration:** Cloud Workflows, Cloud Scheduler
- **Compute:** Cloud Functions (v2), Cloud Run, Dataflow
- **Machine Learning:** BigQuery ML (ARIMA_PLUS, Change Point Detection)
- **Data Storage:** BigQuery, Spanner, Cloud Storage
- **Low-Latency Serving:** Memorystore (Redis)
- **Messaging:** Pub/Sub
- **Infrastructure as Code:** Terraform

## Project Structure

- **`infra/`**: Terraform configurations for deploying the necessary infrastructure.
    - **`envs/`**: Environment-specific configurations (`dev`, `prod`).
    - **`modules/`**: Reusable Terraform modules (Cloud Fabric and Custom).
- **`src/`**: Source code for the MLOps workflows and functions.
    - **`anomaly-detection-workflow/`**: End-to-end time-series anomaly detection pipeline.
    - **`early-detection-workflow/`**: Change point detection and forecasting with Slack alerts.
    - **`feedback-collection-function/`**: User feedback processing for model refinement.
    - **`utility/`**: SQL scripts and Python utilities for data simulation and metrics.

## Key Workflows

### Anomaly Detection Workflow
An end-to-end pipeline orchestrated by Cloud Workflows. It uses BigQuery ML for time-series forecasting and anomaly detection, storing results in Memorystore (Redis) for low-latency access by downstream applications.
For more details, see [src/anomaly-detection-workflow/README.md](src/anomaly-detection-workflow/README.md).

### Early Detection Workflow
A pipeline focused on identifying sudden increases in time-series data using change point detection, forecasting future values, and triggering Slack alerts when thresholds are predicted to be exceeded.
For more details, see [src/early-detection-workflow/README.md](src/early-detection-workflow/README.md).

## Getting Started

### Cloning the Repository

To clone this repository, you need to authenticate with Google Cloud and configure Git to use `gcloud` as a credential helper.

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

## Infrastructure Deployment

The infrastructure is managed using Terraform. To deploy to the development environment:

1.  Navigate to the dev environment directory:
    ```bash
    cd infra/envs/dev
    ```
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Plan and apply changes:
    ```bash
    terraform plan
    terraform apply
    ```
