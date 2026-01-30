output "cluster_name" {
  value = data.terraform_remote_state.eks.outputs.cluster_name
}

output "cluster_endpoint" {
  value = data.terraform_remote_state.eks.outputs.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = data.terraform_remote_state.eks.outputs.cluster_ca_certificate
}

output "cluster_oidc_issuer" {
  value = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer
}

output "oidc_provider_arn" {
  value = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}

output "vpc_id" {
  value = data.terraform_remote_state.network.outputs.vpc_id
}
