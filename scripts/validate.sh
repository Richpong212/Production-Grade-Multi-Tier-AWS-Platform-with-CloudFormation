#!/usr/bin/env bash
set -euo pipefail

echo "Validating main template..."
aws cloudformation validate-template --template-body file://main.yaml > /dev/null
echo "✓ main.yaml is valid"

echo "Validating network template..."
aws cloudformation validate-template --template-body file://template-structure/network/network.yaml > /dev/null
echo "✓ network.yaml is valid"

echo "Validating security template..."
aws cloudformation validate-template --template-body file://template-structure/security/security.yaml > /dev/null
echo "✓ security.yaml is valid"

echo "Validating ALB template..."
aws cloudformation validate-template --template-body file://template-structure/alb/alb.yaml > /dev/null
echo "✓ alb.yaml is valid"

echo "Validating secrets template..."
aws cloudformation validate-template --template-body file://template-structure/secrets/secrets.yaml > /dev/null
echo "✓ secrets.yaml is valid"

if [ -f template-structure/compute/compute.yaml ]; then
  echo "Validating compute template..."
  aws cloudformation validate-template --template-body file://template-structure/compute/compute.yaml > /dev/null
  echo "✓ compute.yaml is valid"
fi

echo "All templates validated successfully."