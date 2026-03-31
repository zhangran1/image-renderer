# Redis Memorystore instance for anomaly threshold caching
module "redis_memorystore" {
  source = "../../modules/custom/redis-memorystore"

  name                    = var.app_redis_name
  tier                    = var.app_redis_tier
  memory_size_gb          = var.app_redis_memory_size_gb
  location_id             = var.app_redis_location_id
  alternative_location_id = var.app_redis_alternative_location_id

  network            = var.app_redis_vpc_network
  service_range_name = var.app_redis_service_range_name

  redis_version = var.app_redis_version
  display_name  = var.app_redis_display_name

  labels = {
    env  = var.app_redis_env
    team = var.app_redis_team
  }

  maintenance_policy = var.app_redis_maintenance_policy
}
