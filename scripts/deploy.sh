#!/usr/bin/env bash
set -euo pipefail

echo "AWS Account:"
aws sts get-caller-identity --query Account --output text

echo "AWS Region:"
aws configure get region

ENVIRONMENT="${1:-dev}"

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
  echo "❌ Invalid environment. Use: dev or prod"
  exit 1
fi

STACK_NAME="multi-tier-${ENVIRONMENT}"
PARAM_FILE="parameters/${ENVIRONMENT}.json"
TEMPLATE_BUCKET="codegenitor-cfn-templates"

echo "======================================"
echo "🚀 Deploying environment: ${ENVIRONMENT}"
echo "📦 Stack name: ${STACK_NAME}"
echo "📄 Parameter file: ${PARAM_FILE}"
echo "======================================"

# 🔒 Extra safety for prod
if [[ "$ENVIRONMENT" == "prod" ]]; then
  read -p "⚠️ You are deploying to PROD. Are you sure? (yes/no): " CONFIRM
  if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Deployment cancelled."
    exit 1
  fi
fi

echo "🔍 Validating templates..."
./scripts/validate.sh

echo "☁️ Uploading templates to S3..."
aws s3 cp template-structure/network/network.yaml "s3://${TEMPLATE_BUCKET}/templates/network.yaml"
aws s3 cp template-structure/security/security.yaml "s3://${TEMPLATE_BUCKET}/templates/security.yaml"
aws s3 cp template-structure/alb/alb.yaml "s3://${TEMPLATE_BUCKET}/templates/alb.yaml"
aws s3 cp template-structure/compute/compute.yaml "s3://${TEMPLATE_BUCKET}/templates/compute.yaml"
aws s3 cp template-structure/database/database.yaml "s3://${TEMPLATE_BUCKET}/templates/database.yaml"
aws s3 cp template-structure/monitoring/monitoring.yaml "s3://${TEMPLATE_BUCKET}/templates/monitoring.yaml"
aws s3 cp app/userdata.sh "s3://${TEMPLATE_BUCKET}/scripts/userdata.sh"
aws s3 cp main.yaml "s3://${TEMPLATE_BUCKET}/main.yaml"
aws s3 cp template-structure/secrets/secrets.yaml "s3://${TEMPLATE_BUCKET}/templates/secrets.yaml"
echo "🔎 Checking if stack exists..."
if aws cloudformation describe-stacks --stack-name "${STACK_NAME}" >/dev/null 2>&1; then
  echo "🔄 Stack exists. Updating..."

  set +e
  UPDATE_OUTPUT=$(aws cloudformation update-stack \
    --stack-name "${STACK_NAME}" \
    --template-body file://main.yaml \
    --parameters file://"${PARAM_FILE}" \
    --capabilities CAPABILITY_IAM 2>&1)
  UPDATE_EXIT=$?
  set -e

  if [ ${UPDATE_EXIT} -ne 0 ]; then
    if echo "${UPDATE_OUTPUT}" | grep -q "No updates are to be performed"; then
      echo "ℹ️ No changes detected."
      exit 0
    else
      echo "${UPDATE_OUTPUT}"
      exit ${UPDATE_EXIT}
    fi
  fi

  echo "⏳ Waiting for update to complete..."
  aws cloudformation wait stack-update-complete --stack-name "${STACK_NAME}"
  echo "✅ Update complete"

else
  echo "🆕 Stack does not exist. Creating..."

  aws cloudformation create-stack \
    --stack-name "${STACK_NAME}" \
    --template-body file://main.yaml \
    --parameters file://"${PARAM_FILE}" \
    --capabilities CAPABILITY_IAM

  echo "⏳ Waiting for creation to complete..."
  aws cloudformation wait stack-create-complete --stack-name "${STACK_NAME}"
  echo "✅ Creation complete"
fi

echo "📊 Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs" \
  --output table