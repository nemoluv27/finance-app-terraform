locals {
  oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  oidc_provider_url = replace(
    data.terraform_remote_state.eks.outputs.oidc_provider_url,
    "https://", ""
  )
}

resource "aws_iam_role" "external_secrets" {
  name = "external-secrets-irsa-prod"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider_url}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "external_secrets" {
  name = "external-secrets-policy-prod"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}