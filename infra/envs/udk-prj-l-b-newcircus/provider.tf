terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.17.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.17.0"
    }
  }
}

provider "google" {
  project = var.provider_project_id
  region  = var.provider_region
}

provider "google-beta" {
  project = var.provider_project_id
  region  = var.provider_region
}
