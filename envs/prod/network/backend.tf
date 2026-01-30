terraform {
  backend "s3" {
    bucket         = "finance-app-tfstate-prod"
    key            = "network/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "finance-app-terraform-lock-prod"
    encrypt        = true
  }
}
