#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
  echo "❌ Invalid environment. Use: dev or prod"
  exit 1
fi

STACK_NAME="multi-tier-${ENVIRONMENT}"
PARAM_FILE="parameters/${ENVIRONMENT}.json"
TEMPLATE_BUCKET="codegenitor-cfn-templates"

if [[ ! -f "$PARAM_FILE" ]]; then
  echo "❌ Parameter file not found: ${PARAM_FILE}"
  exit 1
fi

echo "AWS Account:"
aws sts get-caller-identity --query Account --output text

echo "AWS Region: ${AWS_REGION:-${AWS_DEFAULT_REGION:-not-set}}"

echo "======================================"
echo "🚀 Deploying environment: ${ENVIRONMENT}"
echo "📦 Stack name: ${STACK_NAME}"
echo "📄 Parameter file: ${PARAM_FILE}"
echo "🪣 Template bucket: ${TEMPLATE_BUCKET}"
echo "======================================"

echo "🔍 Validating templates..."
./scripts/validate.sh

echo "☁️ Uploading templates to S3..."
aws s3 cp template-structure/network/network.yaml "s3://${TEMPLATE_BUCKET}/templates/network.yaml"
aws s3 cp template-structure/security/security.yaml "s3://${TEMPLATE_BUCKET}/templates/security.yaml"
aws s3 cp template-structure/alb/alb.yaml "s3://${TEMPLATE_BUCKET}/templates/alb.yaml"
aws s3 cp template-structure/compute/compute.yaml "s3://${TEMPLATE_BUCKET}/templates/compute.yaml"
aws s3 cp template-structure/database/database.yaml "s3://${TEMPLATE_BUCKET}/templates/database.yaml"
aws s3 cp template-structure/monitoring/monitoring.yaml "s3://${TEMPLATE_BUCKET}/templates/monitoring.yaml"
aws s3 cp template-structure/secrets/secrets.yaml "s3://${TEMPLATE_BUCKET}/templates/secrets.yaml"
aws s3 cp app/userdata.sh "s3://${TEMPLATE_BUCKET}/scripts/userdata.sh"
aws s3 cp main.yaml "s3://${TEMPLATE_BUCKET}/main.yaml"

echo "🚀 Deploying CloudFormation stack..."
aws cloudformation deploy \
  --stack-name "${STACK_NAME}" \
  --template-file main.yaml \
  --parameter-overrides file://"${PARAM_FILE}" \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset

echo "✅ Deployment finished"

echo "📊 Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs" \
  --output table