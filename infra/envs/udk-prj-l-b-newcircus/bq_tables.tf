locals {
  pattern_defaults = {
    # ─ Pattern 1 : DAY / 365 
    1 = {
      partition_type               = "DAY"
      partition_field              = "last_modified_date"
      partition_expiration_days    = 365
      require_partition_filter     = true
      clustering_fields            = []        
    }

    # ─ Pattern 2 : DAY / 9855
    2 = {
      partition_type               = "DAY"
      partition_field              = "pege_modified_at"
      partition_expiration_days    = 9855
      require_partition_filter     = true
      clustering_fields            = []
    }

    # ─ Pattern 3 : DAY / 9855
    3 = {
      partition_type               = "DAY"
      partition_field              = "updated_at"
      partition_expiration_days    = 9855
      require_partition_filter     = true
      clustering_fields            = []
    }
    
    # ─ Pattern 4 : DAY / 1095
    4 = {
      partition_type               = "DAY"
      partition_field              = "updated_at"
      partition_expiration_days    = 1095
      require_partition_filter     = true
      clustering_fields            = []
    }

    # ─ Pattern 5 : DAY / 9855
    5 = {
      partition_type               = "DAY"
      partition_field              = "last_updated"
      partition_expiration_days    = 9855
      require_partition_filter     = true
      clustering_fields            = []
    }

    # ─ Pattern 6 : DAY / 365
    6 = {
      partition_type               = "DAY"
      partition_field              = "updated_at"
      partition_expiration_days    = 365
      require_partition_filter     = true
      clustering_fields            = []
    }
      # ─ Pattern 7 : DAY / 365
    7 = {
      partition_type               = "DAY"
      partition_field              = "time_col"
      partition_expiration_days    = 365
      require_partition_filter     = true
      clustering_fields            = []
    }

    # ─ Pattern 8 : HOUR / 366
    8 = {
      partition_type               = "HOUR"
      partition_field              = "udkTimeStamp"
      partition_expiration_days    = 366
      require_partition_filter     = true
      clustering_fields            = ["host"]        
    }

    # ─ Pattern 9 : HOUR / 95
    9 = {
      partition_type               = "HOUR"
      partition_field              = "udkTimeStamp"
      partition_expiration_days    = 95
      require_partition_filter     = true
      clustering_fields            = []
    }

    # ─ Pattern 10 : HOUR / 365
    10 = {
      partition_type               = "HOUR"
      partition_field              = "udkTimeStamp"
      partition_expiration_days    = 365
      require_partition_filter     = true
      clustering_fields            = []    
    }

    # ─ Pattern 11 : DAY / 365 (timestamp)
    11 = {
      partition_type               = "DAY"
      partition_field              = "timestamp"
      partition_expiration_days    = 365
      require_partition_filter     = true
      clustering_fields            = ["project_id", "workflow_name", "action"]
    }

    # ─ Pattern 12 : DAY / 365 (feedback_at)
    12 = {
      partition_type               = "DAY"
      partition_field              = "feedback_at"
      partition_expiration_days    = 365
      require_partition_filter     = false
      clustering_fields            = ["series_id", "label_type", "reason_category"]
    }

    # ─ Pattern 13 : DAY / 365 (timestamp)
    13 = {
      partition_type               = "DAY"
      partition_field              = "timestamp"
      partition_expiration_days    = 365
      require_partition_filter     = false
      clustering_fields            = ["workflow_name", "action", "execution_id"]
    }
  }

  table_cfgs = {
    for t in var.tables :         
    t.table_id => merge(         
      {
        dataset_id  = t.dataset_id
        schema_path = t.schema_path
        labels      = var.labels
      },
      lookup(local.pattern_defaults, t.pattern, {}) 
    )
  }
}

module "bq_tables" {
  source   = "../../modules/table"
  for_each = local.table_cfgs

  project_id  = var.app_bigquery_dataset_project_id
  table_id    = each.key
  dataset_id  = each.value.dataset_id
  schema_path = each.value.schema_path

  partition_type               = lookup(each.value, "partition_type", null)
  partition_field              = lookup(each.value, "partition_field", null)
  partition_expiration_days    = lookup(each.value, "partition_expiration_days", null)
  require_partition_filter     = lookup(each.value, "require_partition_filter", true)
  clustering_fields            = lookup(each.value, "clustering_fields", [])

  labels = lookup(each.value, "labels", {})
  deletion_protection = lookup(each.value, "deletion_protection", false)

  depends_on = [
    module.app_bigquery_dataset
  ]
}
