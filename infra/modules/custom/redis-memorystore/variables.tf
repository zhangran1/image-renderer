

variable "name" {
  description = "The ID of the instance or a fully qualified identifier for the instance."
  type        = string
}

variable "tier" {
  description = "The service tier of the instance. Must be one of these values: BASIC, STANDARD_HA"
  type        = string
  default     = "STANDARD_HA"
}

variable "memory_size_gb" {
  description = "Redis memory size in GiB."
  type        = number
  default     = 1
}

variable "location_id" {
  description = "The zone where the instance will be provisioned. If not provided, the service will choose a zone for the instance."
  type        = string
}

variable "alternative_location_id" {
  description = "The alternative zone where the instance will be provisioned."
  type        = string
  default     = null
}

variable "network" {
  description = "The fully qualified URL of the reserved IP range for peering."
  type        = string
}

variable "redis_version" {
  description = "The version of Redis software."
  type        = string
  default     = "REDIS_7_2"
}

variable "display_name" {
  description = "An arbitrary and optional user-provided name for the instance."
  type        = string
  default     = null
}

variable "service_range_name" {
  description = "Name for the google_compute_global_address resource created for private service connection."
  type        = string
  default     = "redis-address"
}


variable "labels" {
  description = "A map of labels to apply to the Redis instance."
  type        = map(string)
  default     = {}
}

variable "maintenance_policy" {
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
