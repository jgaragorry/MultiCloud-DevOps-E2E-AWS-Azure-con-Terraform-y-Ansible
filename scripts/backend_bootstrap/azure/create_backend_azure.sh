#!/bin/bash
set -e

# --- Configuración ---
# export LOCATION="eastus"
# export BASE_NAME="wstfstate$(date +%s | tail -c 4)"

if [ -z "$LOCATION" ] || [ -z "$BASE_NAME" ]; then
  echo "Error: Por favor defina LOCATION y BASE_NAME."
  echo "Ejemplo: export LOCATION=eastus"
  echo "Ejemplo: export BASE_NAME=wstfstate$(date +%s | tail -c 4)"
  exit 1
fi

RG_NAME="rg-${BASE_NAME}-backend"
SA_NAME="st${BASE_NAME}$RANDOM"
SA_NAME=$(echo "$SA_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g' | cut -c 1-24)
CONTAINER_NAME="tfstate"

TAG_PROJECT="tf-backend"
TAG_ENV="management"
TAG_OWNER="sre-admin"

echo "--- 1. Creando Resource Group ($RG_NAME) para el backend ---"
az group create \
  --name $RG_NAME \
  --location $LOCATION \
  --tags project=$TAG_PROJECT env=$TAG_ENV owner=$TAG_OWNER

echo "--- 2. Creando Storage Account ($SA_NAME) ---"
az storage account create \
  --name $SA_NAME \
  --resource-group $RG_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --tags project=$TAG_PROJECT env=$TAG_ENV owner=$TAG_OWNER

echo "--- 3. Habilitando Versionado y Soft-Delete (SRE) ---"
az storage account blob-service-properties update \
  --account-name $SA_NAME \
  --resource-group $RG_NAME \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 7

echo "--- 4. Creando Contenedor ($CONTAINER_NAME) ---"
ACCOUNT_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $SA_NAME --query '[0].value' -o tsv)

az storage container create \
  --name $CONTAINER_NAME \
  --account-name $SA_NAME \
  --account-key $ACCOUNT_KEY

echo "--- Backend Azure Creado Exitosamente ---"
echo "Resource Group: $RG_NAME"
echo "Storage Account: $SA_NAME"
echo "Container: $CONTAINER_NAME"
