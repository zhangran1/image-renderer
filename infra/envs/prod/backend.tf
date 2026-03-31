terraform {
  backend "gcs" {
    bucket = "udk-prj-l-b-491204-terraform-state"
    prefix = "env/prod"
  }
}
