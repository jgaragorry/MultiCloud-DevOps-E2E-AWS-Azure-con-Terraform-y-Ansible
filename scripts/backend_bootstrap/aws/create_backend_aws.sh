#!/bin/bash
set -e 

# --- Configuración (Sin Hardcoding) ---
# El usuario debe definir estas variables de entorno
# export AWS_REGION="us-east-1"
# export BASE_NAME="wstfstate$(date +%s | tail -c 4)"

if [ -z "$AWS_REGION" ] || [ -z "$BASE_NAME" ]; then
  echo "Error: Por favor defina las variables de entorno AWS_REGION y BASE_NAME."
  echo "Ejemplo: export AWS_REGION=us-east-1"
  echo "Ejemplo: export BASE_NAME=wstfstate$(date +%s | tail -c 4)"
  exit 1
fi

S3_BUCKET_NAME="${BASE_NAME}-tfstate"
DYNAMO_TABLE_NAME="${BASE_NAME}-tflock"
TAG_PROJECT="tf-backend"
TAG_ENV="management"
TAG_OWNER="sre-admin"

echo "--- 1. Creando Bucket S3 ($S3_BUCKET_NAME) para el estado ---"
aws s3api create-bucket \
  --bucket $S3_BUCKET_NAME \
  --region $AWS_REGION \
  --acl private \
  --create-bucket-configuration LocationConstraint=$AWS_REGION

echo "--- 2. Habilitando Versionado (SRE) ---"
aws s3api put-bucket-versioning \
  --bucket $S3_BUCKET_NAME \
  --versioning-configuration Status=Enabled

echo "--- 3. Habilitando Cifrado (Security) ---"
aws s3api put-bucket-encryption \
  --bucket $S3_BUCKET_NAME \
  --server-side-encryption-configuration '{
      "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
    }'

echo "--- 4. Bloqueando Acceso Público (Security) ---"
aws s3api put-public-access-block \
  --bucket $S3_BUCKET_NAME \
  --public-access-block-configuration '{
      "BlockPublicAcls": true, "IgnorePublicAcls": true,
      "BlockPublicPolicy": true, "RestrictPublicBuckets": true
    }'

echo "--- 5. Aplicando Tags (FinOps) ---"
aws s3api put-bucket-tagging \
  --bucket $S3_BUCKET_NAME \
  --tagging "TagSet=[
      {Key=project,Value=$TAG_PROJECT},
      {Key=env,Value=$TAG_ENV},
      {Key=owner,Value=$TAG_OWNER}
    ]"

echo "--- 6. Creando Tabla DynamoDB ($DYNAMO_TABLE_NAME) para Locking ---"
aws dynamodb create-table \
  --table-name $DYNAMO_TABLE_NAME \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
  --tags Key=project,Value=$TAG_PROJECT Key=env,Value=$TAG_ENV Key=owner,Value=$TAG_OWNER \
  --region $AWS_REGION

echo "--- Backend AWS Creado Exitosamente ---"
echo "Bucket S3: $S3_BUCKET_NAME"
echo "Tabla DynamoDB: $DYNAMO_TABLE_NAME"
