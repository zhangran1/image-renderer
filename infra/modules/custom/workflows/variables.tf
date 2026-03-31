
variable "project_id" {
  description = "The project ID where the Workflow will be deployed."
  type        = string
}

variable "name" {
  description = "Name of the Workflow."
  type        = string
}

variable "region" {
  description = "Region of the Workflow."
  type        = string
}

variable "description" {
  description = "Description of the Workflow."
  type        = string
  default     = null
}

variable "service_account" {
  description = "Service account email or ID to be associated with the workflow."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Whether to prevent Terraform from destroying the workflow."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to attach to the workflow."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to attach to the workflow."
  type        = map(string)
  default     = {}
}

variable "source_contents" {
  description = "The YAML or JSON execution instructions for the workflow."
  type        = string
  default     = null
}

variable "workflow_trigger" {
  description = "Configuration for triggering the workflow via Cloud Scheduler."
  type = object({
    cloud_scheduler = optional(object({
      name                  = string
      cron                  = string
      time_zone             = optional(string, "Etc/UTC")
      deadline              = optional(string)
      service_account_email = optional(string)
      retry_count           = optional(number, 1)
    }))
  })
  default = {}
}
