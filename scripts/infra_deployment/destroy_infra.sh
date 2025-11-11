#!/bin/bash
set -e

# 1. Descubre la ruta absoluta del propio script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# 2. Navega 2 niveles arriba para encontrar la raíz del proyecto
PROJECT_ROOT=$( cd -- "$SCRIPT_DIR/../../" &> /dev/null && pwd )
# 3. Define el directorio de Terraform
TERRAFORM_DIR="$PROJECT_ROOT/terraform_infra"

echo "--- Navegando al directorio de Terraform: $TERRAFORM_DIR ---"
cd $TERRAFORM_DIR

echo "--- ATENCIÓN: Destruyendo la infraestructura (VMs, VPCs...) ---"
echo "--- Esto NO destruirá el backend (el .tfstate) ---"
read -p "Escriba 'destruir' para confirmar: " confirm
if [ "$confirm" != "destruir" ]; then
  echo "Cancelado."
  cd - > /dev/null
  exit 0
fi

echo "--- Inicializando Terraform (por si acaso) ---"
terraform init -reconfigure

echo "--- Destruyendo... ---"
terraform destroy -auto-approve

echo "--- ¡Destrucción completada! ---"
cd - > /dev/null
