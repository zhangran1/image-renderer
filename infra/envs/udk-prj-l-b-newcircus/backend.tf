terraform {
  backend "gcs" {
    bucket = "udk-prj-l-b-newcircus-491204-terraform-state"
    prefix = "env/udk-prj-l-b-newcircus"
  }
}
