output "external_secrets_namespace" {
  value = helm_release.external_secrets.namespace
}

output "external_secrets_irsa_role_arn" {
  value = aws_iam_role.external_secrets.arn
}
