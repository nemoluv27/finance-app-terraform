data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "finance-app-tfstate-prod"
    key    = "eks/terraform.tfstate"
    region = "ca-central-1"
  }
}
