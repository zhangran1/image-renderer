# ---------------------------------------------------------------------------------------------------------------------
# Provider Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "provider_project_id" {
  description = "Project ID for the provider."
  type        = string
}

variable "provider_region" {
  description = "Region for the provider."
  type        = string
  default     = "us-central1"
}

# ---------------------------------------------------------------------------------------------------------------------
# BigQuery Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "app_bigquery_dataset_project_id" {
  description = "Project ID for the application analytics dataset."
  type        = string
}

variable "bigquery_datasets" {
  description = "A map of BigQuery dataset configurations."
  type = map(object({
    id       = string
    location = optional(string, "us-central1")
    iam      = optional(map(list(string)), {})
    env      = string
    team     = string
  }))
  default = {}
}

variable "tables" {
  description = "List of table definitions including schema path and pattern."
  type = list(object({
    table_id    = string
    dataset_id  = string
    schema_path = string
    pattern     = number
  }))
  default = []
}

variable "labels" {
  description = "Labels for resources."
  type        = map(string)
  default     = {}
}


# ---------------------------------------------------------------------------------------------------------------------
# Pub/Sub Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "pubsub_topic_project_id" {
  description = "Project ID for the Pub/Sub topic."
  type        = string
}

variable "pubsub_topic_env" {
  description = "Environment label for the Pub/Sub topic."
  type        = string
}

variable "pubsub_topic_team" {
  description = "Team label for the Pub/Sub topic."
  type        = string
}

variable "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic."
  type        = string
}

variable "pubsub_invoker_sa_project_id" {
  description = "Project ID for the Pub/Sub invoker SA."
  type        = string
}

variable "pubsub_invoker_sa_env" {
  description = "Environment label for the Pub/Sub invoker SA."
  type        = string
}

variable "pubsub_invoker_sa_team" {
  description = "Team label for the Pub/Sub invoker SA."
  type        = string
}

variable "pubsub_invoker_sa_name" {
  description = "The name of the Pub/Sub invoker SA."
  type        = string
}

variable "pubsub_subscriptions" {
  description = "Map of subscription definitions including push config for Cloud Function."
  type        = any
}

variable "pubsub_invoker_sa_target_project_id" {
  description = "Project ID where the Pub/Sub invoker SA will be granted IAM roles."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Network Events Dataflow Job
# ---------------------------------------------------------------------------------------------------------------------

variable "network_events_to_bq_project_id" {
  description = "Project ID for the Network Events Dataflow job."
  type        = string
}

variable "network_events_to_bq_region" {
  description = "Region for the Network Events Dataflow job."
  type        = string
}

variable "network_events_to_bq_template_bucket" {
  description = "GCS bucket name where the Dataflow Flex Template JSON is stored."
  type        = string
}

variable "network_events_to_bq_template_bucket_storage_class" {
  description = "The storage class of the Dataflow Flex Template bucket."
  type        = string
  default     = "STANDARD"
}

variable "network_events_to_bq_env" {
  description = "Environment label for the Dataflow job."
  type        = string
}

variable "network_events_to_bq_team" {
  description = "Team label for the Dataflow job."
  type        = string
}

variable "network_events_to_bq_subnetwork" {
  description = "Subnetwork URI for the Dataflow job"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Spanner Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "network_detection_spanner_project_id" {
  description = "Project ID where the Spanner instance will be deployed."
  type        = string
}

variable "network_detection_spanner_instance_config" {
  description = "Configuration attributes for the Spanner instance (name, config, autoscaling, labels, processing_units)."
  type = object({
    name         = string
    display_name = optional(string)
    edition      = optional(string)
    config = object({
      name = string
    })
    processing_units = optional(number)
    autoscaling = optional(object({
      limits = object({
        max_processing_units = number
        min_processing_units = number
      })
      targets = object({
        high_priority_cpu_utilization_percent = number
        storage_utilization_percent           = number
      })
    }))
    labels = optional(map(string), {})
  })
}

variable "network_detection_spanner_databases" {
  description = "Map of database definitions including dialect, retention, DDL, and IAM rules."
  type = map(object({
    database_dialect         = optional(string)
    version_retention_period = optional(string)
    deletion_protection      = optional(bool)
    ddl                      = optional(list(string), [])
    iam                      = optional(map(list(string)), {})
  }))
  default = {}
}

# ---------------------------------------------------------------------------------------------------------------------
# Redis Instance Configuration
# ---------------------------------------------------------------------------------------------------------------------
variable "app_redis_name" {
  description = "The ID of the Redis instance or a fully qualified identifier."
  type        = string
}

variable "app_redis_tier" {
  description = "The service tier of the instance. Usually BASIC or STANDARD_HA."
  type        = string
  default     = "STANDARD_HA"
}

variable "app_redis_memory_size_gb" {
  description = "Redis memory size in GiB."
  type        = number
  default     = 1
}

# Location Configuration
variable "app_redis_location_id" {
  description = "The primary zone where the instance will be provisioned."
  type        = string
}

variable "app_redis_alternative_location_id" {
  description = "The alternative zone where the instance will be provisioned (useful for STANDARD_HA)."
  type        = string
  default     = null
}

# Network Configuration
variable "app_redis_vpc_network" {
  description = "The fully qualified URL of the VPC network to which the Redis instance connects."
  type        = string
}

variable "app_redis_service_range_name" {
  description = "Name for the google_compute_global_address resource created for private service connection."
  type        = string
  default     = "app-redis-address"
}

# Additional Settings
variable "app_redis_version" {
  description = "The version of Redis software (e.g., REDIS_7_2)."
  type        = string
  default     = "REDIS_7_2"
}

variable "app_redis_display_name" {
  description = "An arbitrary and optional user-provided name for the Redis instance."
  type        = string
  default     = "App Cache"
}

variable "app_redis_env" {
  description = "Environment label for the Redis instance."
  type        = string
}

variable "app_redis_team" {
  description = "Team label for the Redis instance."
  type        = string
}

variable "app_redis_maintenance_policy" {
  description = "The maintenance policy for the Redis instance."
  type = object({
    description = optional(string)
    weekly_maintenance_window = optional(list(object({
      day = string
      start_time = object({
        hours   = number
        minutes = number
        seconds = number
        nanos   = number
      })
    })))
  })
  default = null
}
