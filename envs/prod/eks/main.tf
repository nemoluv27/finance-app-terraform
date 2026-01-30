provider "aws" {
  region = "ca-central-1"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "finance-app-tfstate-prod"
    key    = "network/terraform.tfstate"
    region = "ca-central-1"
  }
}

resource "aws_eks_cluster" "this" {
  name     = "finance-app-eks-prod"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.29"

  vpc_config {
    subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}
