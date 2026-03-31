# UDK Project L-B Newcircus Terraform Environment

This document provides an overview of the Terraform resources, dependencies, and configuration for the `udk-prj-l-b-newcircus` environment.

## Table of Contents

*   [Resources](#resources)
    *   [BigQuery](#bigquery)
    *   [Dataflow](#dataflow)
    *   [Pub/Sub](#pubsub)
    *   [Redis Memorystore](#redis-memorystore)
    *   [Spanner](#spanner)
    *   [Cloud Storage](#cloud-storage)
*   [General Instructions](#general-instructions)
    *   [GCloud Authentication](#gcloud-authentication)
    *   [Terraform Initialization](#terraform-initialization)
    *   [Terraform Plan](#terraform-plan)
    *   [Terraform Apply](#terraform-apply)

## Resources

### BigQuery

*   **Description:** This environment uses BigQuery for storing application analytics events and core data. It includes datasets and tables with partitioning and clustering.
*   **Module Dependencies:**
    *   `cloud-fabric/bigquery`: This module creates the BigQuery datasets. This dependency is necessary because datasets must exist before tables can be created within them.
    *   `table`: This custom module creates the BigQuery tables. It depends on the `cloud-fabric/bigquery` module to ensure datasets are available.
*   **Configuration Variables:**
    *   `app_bigquery_dataset_project_id`
    *   `bigquery_datasets`
    *   `tables`

### Dataflow

*   **Description:** A Dataflow job streams data from Kafka to BigQuery.
*   **Module Dependencies:**
    *   `custom/dataflow`: This module deploys the Dataflow job. A GCS bucket is a dependency for storing the Dataflow template.
*   **Configuration Variables:**
    *   `network_events_to_bq_project_id`
    *   `network_events_to_bq_region`

### Pub/Sub

*   **Description:** A Pub/Sub topic with a push subscription is used to trigger a Cloud Function.
*   **Module Dependencies:**
    *   `cloud-fabric/iam-service-account`: This module creates a service account for the Pub/Sub subscription to authenticate with the Cloud Function it triggers.
    *   `cloud-fabric/pubsub`: This module creates the Pub/Sub topic and subscription.
*   **Configuration Variables:**
    *   `pubsub_topic_project_id`
    *   `pubsub_topic_name`

### Redis Memorystore

*   **Description:** A Redis Memorystore instance is used for caching.
*   **Module Dependencies:**
    *   `custom/redis-memorystore`: This module deploys the Redis instance.
*   **Configuration Variables:**
    *   `app_redis_name`
    *   `app_redis_tier`
    *   `app_redis_memory_size_gb`

### Spanner

*   **Description:** A Spanner instance is used for network detection.
*   **Module Dependencies:**
    *   `cloud-fabric/spanner-instance`: This module deploys the Spanner instance and its databases.
*   **Configuration Variables:**
    *   `network_detection_spanner_project_id`
    *   `network_detection_spanner_instance_config`

### Cloud Storage

*   **Description:** A GCS bucket is used to store Dataflow Flex Templates.
*   **Module Dependencies:**
    *   `cloud-fabric/gcs`: This module creates the GCS bucket.
*   **Configuration Variables:**
    *   `network_events_to_bq_template_bucket`

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
