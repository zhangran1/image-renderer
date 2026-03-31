resource "google_bigquery_table" "default" {
  project = var.project_id
  dataset_id = var.dataset_id
  table_id = var.table_id
  schema = var.schema_path != null ? file("${path.root}/${var.schema_path}") : null
  clustering = var.clustering_fields
  labels = var.labels
  deletion_protection = var.deletion_protection
  require_partition_filter = var.require_partition_filter
  dynamic "time_partitioning" {
    for_each = var.partition_type != null ? [1] : []
    content {
      type = var.partition_type
      field = var.partition_field
      expiration_ms = var.partition_expiration_days != null ? var.partition_expiration_days * 24 * 60 * 60 * 1000 : null
    }
  }
}
