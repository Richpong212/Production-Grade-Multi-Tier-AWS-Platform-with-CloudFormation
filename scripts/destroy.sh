#!/usr/bin/env bash
set -euo pipefail

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

echo "🔎 Checking if stack exists..."
if ! aws cloudformation describe-stacks --stack-name "${STACK_NAME}" >/dev/null 2>&1; then
  echo "ℹ️ Stack does not exist: ${STACK_NAME}"
  exit 0
fi

echo "🗑️ Deleting stack..."
aws cloudformation delete-stack --stack-name "${STACK_NAME}"

echo "⏳ Waiting for deletion to complete..."
aws cloudformation wait stack-delete-complete --stack-name "${STACK_NAME}"

echo "✅ Stack deleted successfully: ${STACK_NAME}"