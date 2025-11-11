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

# ... (El resto del script no cambia) ...

echo "--- Inicializando Terraform (conectando al backend) ---"
# -reconfigure es útil si cambias de backend (AWS a Azure)
terraform init -reconfigure

echo "--- Validando el código ---"
terraform validate

echo "--- Creando plan de ejecución ---"
terraform plan -out=tfplan

echo "--- Aplicando el plan (desplegando infraestructura) ---"
terraform apply -auto-approve tfplan

echo "--- ¡Despliegue completado! ---"
cd - > /dev/null # Volvemos al directorio original en silencio
