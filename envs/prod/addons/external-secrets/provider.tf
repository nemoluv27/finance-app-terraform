provider "aws" {
  region = "ca-central-1"
}

# EKS 정보 조회
data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

# Kubernetes Provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.eks.outputs.cluster_ca_certificate
  )
  token                  = data.aws_eks_cluster_auth.this.token
}

# Helm Provider (⚠️ block 문법 사용)
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.eks.outputs.cluster_ca_certificate
    )
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
