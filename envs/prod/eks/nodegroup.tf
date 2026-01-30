resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = data.terraform_remote_state.network.outputs.private_subnet_ids

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 5
  }

  instance_types = ["t3.large"]

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr
  ]
}
