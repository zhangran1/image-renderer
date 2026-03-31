# BigQuery Outputs
output "bigquery_dataset_ids" {
  description = "The IDs of the BigQuery datasets created."
  value       = [for d in module.app_bigquery_dataset : d.id]
}

# Redis Outputs for cross-environment state sharing
output "redis_host" {
  description = "The IP address of the Redis instance."
  value       = module.redis_memorystore.host
}

output "redis_port" {
  description = "The port number of the Redis instance."
  value       = module.redis_memorystore.port
}
