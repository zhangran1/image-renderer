provider_project_id = "udk-prj-l-b-newcircus-491204"
provider_region     = "us-central1"

#-------------------------------------------------------------------------------------
# BigQuery Configuration
#-------------------------------------------------------------------------------------
app_bigquery_dataset_project_id = "udk-prj-l-b-newcircus-491204"

bigquery_datasets = {
  model_ops = {
    id       = "model_ops"
    location = "us-central1"
    env      = "dev"
    team     = "data-platform"
    iam      = {}
  }
  feedbacks = {
    id       = "feedbacks"
    location = "us-central1"
    env      = "dev"
    team     = "data-science"
    iam      = {}
  }
}

tables = [
  {
    table_id    = "audit_log"
    dataset_id  = "model_ops"
    schema_path = "src/bq-schemas/udk_tbl_audit_log.json"
    deletion_protection = false
    pattern     = 11
  },
  {
    table_id    = "monthly_feedback"
    dataset_id  = "feedbacks"
    schema_path = "src/bq-schemas/monthly_feedback.json"
    deletion_protection = false
    pattern     = 12
  },
  {
    table_id    = "job_results"
    dataset_id  = "model_ops"
    schema_path = "src/bq-schemas/job_results.json"
    deletion_protection = false
    pattern     = 13
  }
]

#-------------------------------------------------------------------------------------
# Pub/Sub Configuration
#-------------------------------------------------------------------------------------
pubsub_invoker_sa_project_id = "udk-prj-l-b-newcircus-491204"
pubsub_invoker_sa_env        = "dev"
pubsub_invoker_sa_team       = "data-platform"
pubsub_invoker_sa_name       = "pubsub-invoker"
pubsub_topic_project_id = "udk-prj-l-b-newcircus-491204"
pubsub_topic_env        = "dev"
pubsub_topic_team       = "data-platform"
pubsub_topic_name       = "cpu-change-notification-topic"
pubsub_subscriptions = {
  "cpu-change-notification-sub" = {
    ack_deadline_seconds = 60
    push = {
      # The endpoint URL for the push subscription.
      endpoint = "https://us-central1-udk-prj-l-b-newcircus-491204.cloudfunctions.net/my-function"
      oidc_token = {
        # The service account email to be used for OIDC authentication.
        service_account_email = "pubsub-invoker@udk-prj-l-b-newcircus-491204.iam.gserviceaccount.com"
      }
    }
  }
}
pubsub_invoker_sa_target_project_id                 = "udk-prj-l-b-newcircus-491204"

#-------------------------------------------------------------------------------------
#  Dataflow Job Configuration
#-------------------------------------------------------------------------------------
network_events_to_bq_project_id      = "udk-prj-l-b-newcircus-491204"
network_events_to_bq_region          = "us-central1"
network_events_to_bq_env             = "dev"
network_events_to_bq_team            = "data-engineering"
network_events_to_bq_template_bucket = "udk-prj-l-b-newcircus-491204-dataflow-flex-templates"
network_events_to_bq_template_bucket_storage_class = "STANDARD"
network_events_to_bq_subnetwork      = "https://www.googleapis.com/compute/v1/projects/udk-prj-l-b-newcircus-491204/regions/us-central1/subnetworks/test-sub"

#-------------------------------------------------------------------------------------
# Spanner Instance and Database Configuration
#-------------------------------------------------------------------------------------
network_detection_spanner_project_id = "udk-prj-l-b-newcircus-491204"
network_detection_spanner_instance_config = {
  name         = "network-detection"
  display_name = "Network DetectionInstance"
  edition      = "ENTERPRISE"
  config = {
    name = "regional-us-central1"
  }
  # Security/Reliability: Enable autoscaling for better resource handling instead of fixed units
  autoscaling = {
    limits = {
      min_processing_units = 1000
      max_processing_units = 5000
    }
    targets = {
      high_priority_cpu_utilization_percent = 65
      storage_utilization_percent           = 95
    }
  }
  labels = {
    env  = "dev"
    team = "network-security"
  }
  force_destroy = true
}
network_detection_spanner_databases = {
  "network-db" = {
    database_dialect         = "GOOGLE_STANDARD_SQL"
    version_retention_period = "7d"  # Security: Keep 7 days of snapshot data for PITR
    deletion_protection      = false # Security: Prevent accidental destruction
    ddl = [
      <<EOF
      CREATE TABLE network_devices_graph (
        device_id STRING(100) NOT NULL,
        description STRING(MAX),
        connected_devices ARRAY<STRING(100)>
      ) PRIMARY KEY(device_id)
EOF
    ]
  }
}

#-------------------------------------------------------------------------------------
# Redis Memorystore Configuration 
#-------------------------------------------------------------------------------------
app_redis_name                    = "udk-anomaly-memstore"
app_redis_tier                    = "STANDARD_HA"
app_redis_memory_size_gb          = 1
app_redis_location_id             = "us-central1-a"
app_redis_alternative_location_id = null
app_redis_vpc_network        = "projects/udk-prj-l-b-newcircus-491204/global/networks/dws-network"
app_redis_service_range_name = "redis-peering-range"
app_redis_version      = "REDIS_7_2"
app_redis_display_name = "udk-anomaly-memstore"
app_redis_env       = "dev"
app_redis_team      = "data-engineering"
app_redis_maintenance_policy = {
  description = "Weekly maintenance on Sunday at Midnight UTC"
  weekly_maintenance_window = [{
    day = "SUNDAY"
    start_time = {
      hours   = 0
      minutes = 0
      seconds = 0
      nanos   = 0
    }
  }]
}
