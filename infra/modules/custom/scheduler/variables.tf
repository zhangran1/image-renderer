
variable "project_id" {
  description = "Project ID where the Cloud Scheduler job will be deployed."
  type        = string
}

variable "region" {
  description = "Region where the Cloud Scheduler job will be deployed."
  type        = string
}

variable "name" {
  description = "The name of the Cloud Scheduler job."
  type        = string
}

variable "description" {
  description = "The description of the Cloud Scheduler job."
  type        = string
  default     = null
}

variable "schedule" {
  description = "The schedule in cron format."
  type        = string
}

variable "time_zone" {
  description = "The timezone for the schedule."
  type        = string
  default     = "Etc/UTC"
}

variable "attempt_deadline" {
  description = "The deadline for job attempts."
  type        = string
  default     = "320s"
}

variable "retry_count" {
  description = "The number of retries."
  type        = number
  default     = 1
}

variable "http_method" {
  description = "The HTTP method to use for the request."
  type        = string
  default     = "POST"
}

variable "uri" {
  description = "The full URI to send the request to."
  type        = string
}

variable "body" {
  description = "The HTTP request body. It will be base64 encoded automatically."
  type        = string
  default     = null
}

variable "headers" {
  description = "HTTP headers to send with the request."
  type        = map(string)
  default     = {}
}

variable "service_account_email" {
  description = "The service account email to use for OIDC authentication."
  type        = string
}

variable "labels" {
  description = "A map of labels to apply to the Cloud Scheduler job."
  type        = map(string)
  default     = {}
}
