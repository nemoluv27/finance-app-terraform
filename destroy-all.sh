#!/usr/bin/env bash
set -e

ENV=prod
BASE_DIR="$(cd "$(dirname "$0")" && pwd)/envs/$ENV"
REGION="ca-central-1"

destroy_dir () {
  local dir=$1
  echo ""
  echo "💥 Destroying: $dir"
  echo "----------------------------------------"

  cd "$BASE_DIR/$dir"

  terraform init -upgrade
  terraform destroy -auto-approve
}

wait_for_eni_cleanup () {
  local vpc_id=$1
  echo ""
  echo "🔍 Waiting for ENIs in VPC ($vpc_id) to be deleted..."

  while true; do
    eni_count=$(aws ec2 describe-network-interfaces \
      --filters Name=vpc-id,Values="$vpc_id" \
      --query 'NetworkInterfaces | length(@)' \
      --output text)

    if [[ "$eni_count" -eq 0 ]]; then
      echo "✅ All ENIs removed"
      break
    fi

    echo "⏳ ENIs still present: $eni_count ... waiting 20s"
    sleep 20
  done
}

echo ""
echo "========== START TERRAFORM DESTROY =========="

# 🔥 Kubernetes layer 먼저 제거
destroy_dir istio
destroy_dir addons/external-secrets

# 🔥 EKS control plane 제거
destroy_dir eks

# 🔥 VPC ID 확보 (EKS 삭제 후에도 state는 남아 있음)
cd "$BASE_DIR/network"
VPC_ID=$(terraform output -raw vpc_id)

# 🔥 ENI 완전 제거 대기 (ALB / NLB / EKS leftover)
wait_for_eni_cleanup "$VPC_ID"

# 🔥 Infra layer 제거
destroy_dir network

echo ""
echo "🧨 All Terraform stacks destroyed"
echo "=============================================="
