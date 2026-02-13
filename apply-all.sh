#!/usr/bin/env bash
set -e

ENV=prod
BASE_DIR="$(cd "$(dirname "$0")" && pwd)/envs/$ENV"
REGION="ca-central-1"

apply_dir () {
  local dir=$1
  echo ""
  echo "🚀 Applying: $dir"
  echo "----------------------------------------"

  cd "$BASE_DIR/$dir"

  terraform init -upgrade
  terraform apply -auto-approve
}

wait_for_eks () {
  echo ""
  echo "⏳ Waiting for EKS cluster to become ACTIVE..."
  echo "----------------------------------------"

  # EKS stack에서 cluster_name 가져오기
  CLUSTER_NAME=$(terraform -chdir="$BASE_DIR/eks" output -raw cluster_name)

  echo "Cluster Name: $CLUSTER_NAME"

  # AWS CLI wait 사용 (가장 안정적인 방법)
  aws eks wait cluster-active \
    --name "$CLUSTER_NAME" \
    --region "$REGION"

  echo "✅ EKS cluster is ACTIVE"

  echo ""
  echo "⏳ Verifying Kubernetes API accessibility..."
  echo "----------------------------------------"

  # API endpoint 접근 확인 (선택적이지만 안정성 ↑)
  until aws eks describe-cluster \
    --name "$CLUSTER_NAME" \
    --region "$REGION" \
    --query "cluster.status" \
    --output text | grep -q ACTIVE; do
      echo "Still waiting for cluster..."
      sleep 5
  done

  echo "✅ Kubernetes API is reachable"
}

echo ""
echo "========== START TERRAFORM APPLY =========="

apply_dir network
apply_dir eks

# 🔥 여기서 EKS 준비 완료 보장
wait_for_eks

apply_dir addons/external-secrets
apply_dir istio

echo ""
echo "✅ All Terraform stacks applied successfully"
echo "============================================"
