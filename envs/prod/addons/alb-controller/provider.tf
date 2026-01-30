provider "aws" {
  region = "ca-central-1"
}

provider "helm" {
  kubernetes = {
    host = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.eks.outputs.cluster_ca_certificate
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}
