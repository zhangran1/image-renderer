
variable "project_id" {
  description = "The project ID where the Dataflow job will be deployed."
  type        = string
}

variable "region" {
  description = "The region to deploy the Dataflow job."
  type        = string
}

variable "gcs_template_path" {
  description = "The GCS path to the Dataflow Flex Template."
  type        = string
}

variable "labels" {
  description = "Labels to be attached to the Dataflow job."
  type        = map(string)
  default     = {}
}

variable "subnetwork" {
  description = "The subnetwork to which VMs will be assigned."
  type        = string
}
