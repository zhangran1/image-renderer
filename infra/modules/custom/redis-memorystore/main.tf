resource "google_compute_global_address" "service_range" {
  name          = var.service_range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = var.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
}

resource "google_redis_instance" "cache" {
  name           = var.name
  tier           = var.tier
  memory_size_gb = var.memory_size_gb

  location_id             = var.location_id
  alternative_location_id = var.alternative_location_id

  authorized_network = var.network
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  redis_version = var.redis_version
  display_name  = var.display_name

  labels = var.labels

  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy != null ? [var.maintenance_policy] : []
    content {
      description = maintenance_policy.value.description
      dynamic "weekly_maintenance_window" {
        for_each = maintenance_policy.value.weekly_maintenance_window != null ? maintenance_policy.value.weekly_maintenance_window : []
        content {
          day = weekly_maintenance_window.value.day
          start_time {
            hours   = weekly_maintenance_window.value.start_time.hours
            minutes = weekly_maintenance_window.value.start_time.minutes
            seconds = weekly_maintenance_window.value.start_time.seconds
            nanos   = weekly_maintenance_window.value.start_time.nanos
          }
        }
      }
    }
  }

  depends_on = [google_service_networking_connection.private_service_connection]

}