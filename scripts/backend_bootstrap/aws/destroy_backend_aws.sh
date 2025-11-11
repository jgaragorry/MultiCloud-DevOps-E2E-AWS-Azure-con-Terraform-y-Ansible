#!/bin/bash
set -e

# --- Configuración (Debe ser la misma que en la creación) ---
# export AWS_REGION="us-east-1"
# export BASE_NAME="wstfstate1234" 

if [ -z "$AWS_REGION" ] || [ -z "$BASE_NAME" ]; then
  echo "Error: Por favor defina AWS_REGION y BASE_NAME."
  exit 1
fi

S3_BUCKET_NAME="${BASE_NAME}-tfstate"
DYNAMO_TABLE_NAME="${BASE_NAME}-tflock"

echo "--- ATENCIÓN: Esta acción destruirá el backend de Terraform ---"
read -p "Escriba 'destruir' para confirmar: " confirm
if [ "$confirm" != "destruir" ]; then
  echo "Cancelado."
  exit 0
fi

echo "--- 1. Destruyendo Tabla DynamoDB ($DYNAMO_TABLE_NAME) ---"
aws dynamodb delete-table \
  --table-name $DYNAMO_TABLE_NAME \
  --region $AWS_REGION

echo "--- 2. Vaciando y Destruyendo Bucket S3 ($S3_BUCKET_NAME) ---"
aws s3 rb s3://$S3_BUCKET_NAME --force --region $AWS_REGION

echo "--- Backend AWS Destruido ---"
