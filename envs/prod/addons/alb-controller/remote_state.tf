data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "finance-app-tfstate-prod"
    key    = "network/terraform.tfstate"
    region = "ca-central-1"
  }
}