variable "project_id" {}
variable "dataset_id" {}
variable "table_id" {}
variable "schema_path" {}
variable "partition_type" { default = null }
variable "partition_field" { default = null }
variable "partition_expiration_days" { default = null }
variable "require_partition_filter" { default = null }
variable "clustering_fields" { default = [] }
variable "labels" { default = {} }
variable "deletion_protection" { default = false }
