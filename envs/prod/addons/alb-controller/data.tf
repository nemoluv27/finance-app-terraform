data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "finance-app-tfstate-prod"
    key    = "eks/terraform.tfstate"
    region = "ca-central-1"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}


