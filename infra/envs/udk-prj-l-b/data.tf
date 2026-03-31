# Remote state from newcircus environment to share Redis configuration
data "terraform_remote_state" "newcircus" {
  backend = "gcs"
  config = {
    bucket = "udk-prj-l-b-newcircus-491204-terraform-state"
    prefix = "env/udk-prj-l-b-newcircus"
  }
}
