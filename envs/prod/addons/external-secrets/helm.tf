resource "helm_release" "external_secrets" {

  depends_on = [
    data.aws_eks_cluster.this,
    aws_iam_role.external_secrets
  ]

  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.10.3"

  namespace        = "external-secrets"
  create_namespace = true

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      installCRDs = true

      serviceAccount = {
        create = true
        name   = "external-secrets"

        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
        }
      }
    })
  ]
}
