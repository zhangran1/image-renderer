# UDK Project L-B Terraform Environment

This document provides an overview of the Terraform resources, dependencies, and configuration for the `udk-prj-l-b` environment.

## Table of Contents

*   [Resources](#resources)
    *   [Cloud Run](#cloud-run)
    *   [Compute Engine](#compute-engine)
    *   [Cloud Functions](#cloud-functions)
    *   [Cloud Storage](#cloud-storage)
    *   [Cloud Workflows](#cloud-workflows)
*   [General Instructions](#general-instructions)
    *   [GCloud Authentication](#gcloud-authentication)
    *   [Terraform Initialization](#terraform-initialization)
    *   [Terraform Plan](#terraform-plan)
    *   [Terraform Apply](#terraform-apply)

## Resources

### Cloud Run

*   **Description:** The Anomaly Detection Service is deployed as a Cloud Run v2 service. It is configured to be publicly accessible and uses a service account with roles for BigQuery, Redis, and Logging.
*   **Module Dependencies:**
    *   `cloud-fabric/iam-service-account`: This module creates a service account for the Cloud Run service. This is a dependency because the service needs an identity to securely interact with other GCP services.
    *   `cloud-fabric/cloud-run-v2`: This module deploys the Cloud Run service itself.
*   **Configuration Variables:**
    *   `anomaly_detection_service_name`
    *   `anomaly_detection_service_project_id`
    *   `anomaly_detection_service_region`
    *   `anomaly_detection_service_min_instances`
    *   `anomaly_detection_service_max_instances`

### Compute Engine

*   **Description:** A Managed Instance Group (MIG) is used to run the Git Runner. The MIG is configured with an instance template and an autoscaler.
*   **Module Dependencies:**
    *   `cloud-fabric/iam-service-account`: This module creates a service account for the Git Runner instances, allowing them to access necessary resources like Secret Manager.
    *   `cloud-fabric/compute-vm`: This module creates the instance template that defines the configuration of the VMs in the MIG.
    *   `cloud-fabric/compute-mig`: This module creates the MIG, which uses the instance template.
*   **Configuration Variables:**
    *   `git_runner_project_id`
    *   `git_runner_region`
    *   `git_runner_min_replicas`
    *   `git_runner_max_replicas`

### Cloud Functions

*   **Description:** The Anomaly Detection function is deployed as a Cloud Function v2. The function's source code is zipped and uploaded to a Cloud Storage bucket.
*   **Module Dependencies:**
    *   `cloud-fabric/iam-service-account`: This module creates a service account for the Cloud Function, which is necessary for the function to have the permissions to access other resources.
    *   `cloud-fabric/cloud-function-v2`: This module deploys the Cloud Function.
*   **Configuration Variables:**
    *   `anomaly_detection_func_name`
    *   `anomaly_detection_func_project_id`
    *   `anomaly_detection_func_region`
    *   `anomaly_detection_func_min_instances`
    *   `anomaly_detection_func_max_instances`

### Cloud Storage

*   **Description:** A GCS bucket is used to store the source code for the Cloud Function.
*   **Module Dependencies:**
    *   `cloud-fabric/gcs`: This module is used to create the GCS bucket.
*   **Configuration Variables:**
    *   `cloud_functions_bucket_name`
    *   `cloud_functions_bucket_project_id`
    *   `cloud_functions_bucket_region`

### Cloud Workflows

*   **Description:** A Cloud Workflow is used to orchestrate the Anomaly Detection process. The workflow is triggered by a Cloud Scheduler job.
*   **Module Dependencies:**
    *   `cloud-fabric/iam-service-account`: This module creates a service account for the Cloud Workflow and another for the Cloud Scheduler trigger. This is a dependency because the workflow and scheduler need identities to securely interact with other GCP services.
    *   `custom/workflows`: This module deploys the Cloud Workflow and its trigger.
*   **Configuration Variables:**
    *   `anomaly_detection_workflow_name`
    *   `anomaly_detection_workflow_project_id`
    *   `anomaly_detection_workflow_region`

## Remote State Dependencies

This environment depends on the remote state of the `udk-prj-l-b-newcircus` environment to retrieve the configuration for the Redis instance.

*   **`data.tf`**: This file defines a `terraform_remote_state` data source that reads the outputs from the `udk-prj-l-b-newcircus` environment's state file.
*   **Usage**: The `workflows.tf` file references this remote state to get the `redis_host` and `redis_port` and pass them as arguments to the Cloud Workflow.

This allows for a separation of concerns, where the core data infrastructure is managed in a separate environment.

## General Instructions

### GCloud Authentication

Before running Terraform commands, make sure you are authenticated with `gcloud`:

```sh
gcloud auth login
gcloud auth application-default login
```

### Terraform Initialization

Initialize the Terraform workspace:

```sh
terraform init
```

### Terraform Plan

Create an execution plan:

```sh
terraform plan
```

### Terraform Apply

Apply the changes:

```sh
terraform apply
```
