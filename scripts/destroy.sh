#!/usr/bin/env bash
set -euo pipefail

##

ENVIRONMENT="${1:-}"

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
  echo "❌ Invalid environment. Use: dev or prod"
  exit 1
fi

STACK_NAME="multi-tier-${ENVIRONMENT}"

echo "AWS Account:"
aws sts get-caller-identity --query Account --output text

echo "AWS Region: ${AWS_REGION:-${AWS_DEFAULT_REGION:-not-set}}"

echo "======================================"
echo "🔥 Destroying environment: ${ENVIRONMENT}"
echo "📦 Stack name: ${STACK_NAME}"
echo "======================================"

echo "🔎 Resolving stack..."
set +e
STACK_ID=$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].StackId" \
  --output text 2>/tmp/cfn_describe_err)
DESCRIBE_EXIT=$?
set -e

if [[ $DESCRIBE_EXIT -ne 0 ]]; then
  if grep -qi "does not exist\|ValidationError" /tmp/cfn_describe_err; then
    echo "ℹ️ Stack does not exist: ${STACK_NAME}"
    exit 0
  fi

  echo "❌ Failed to describe stack"
  cat /tmp/cfn_describe_err
  exit 1
fi

echo "✅ Found stack id: ${STACK_ID}"

echo "🗑️ Deleting stack..."
aws cloudformation delete-stack --stack-name "${STACK_ID}"

echo "⏳ Waiting for deletion to complete..."

while true; do
  set +e
  STATUS=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_ID}" \
    --query "Stacks[0].StackStatus" \
    --output text 2>/tmp/cfn_wait_err)
  STATUS_EXIT=$?
  set -e

  if [[ $STATUS_EXIT -ne 0 ]]; then
    if grep -qi "does not exist\|ValidationError" /tmp/cfn_wait_err; then
      echo "✅ Stack is fully deleted"
      exit 0
    fi

    echo "❌ Error while checking stack status"
    cat /tmp/cfn_wait_err
    exit 1
  fi

  echo "Current status: ${STATUS}"

  if [[ "${STATUS}" == "DELETE_COMPLETE" ]]; then
    echo "✅ Stack deletion completed"
    exit 0
  fi

  if [[ "${STATUS}" == "DELETE_FAILED" ]]; then
    echo "❌ Stack deletion failed"
    echo "Recent stack events:"
    aws cloudformation describe-stack-events \
      --stack-name "${STACK_ID}" \
      --max-items 20 \
      --query "StackEvents[].[Timestamp,LogicalResourceId,ResourceStatus,ResourceStatusReason]" \
      --output table || true
    exit 1
  fi

  sleep 15
done