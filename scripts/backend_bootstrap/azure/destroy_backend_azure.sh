#!/bin/bash
set -e

# --- Configuración ---
# export BASE_NAME="wstfstate1234"

if [ -z "$BASE_NAME" ]; then
  echo "Error: Por favor defina BASE_NAME."
  exit 1
fi

RG_NAME="rg-${BASE_NAME}-backend"

echo "--- ATENCIÓN: Esta acción destruirá el Resource Group ($RG_NAME) ---"
echo "--- y todo el estado de Terraform almacenado en él. ---"
read -p "Escriba 'destruir' para confirmar: " confirm
if [ "$confirm" != "destruir" ]; then
  echo "Cancelado."
  exit 0
fi

echo "--- Destruyendo Resource Group ($RG_NAME) ---"
az group delete \
  --name $RG_NAME \
  --yes \
  --no-wait

echo "--- Backend Azure Destruido ---"
