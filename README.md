<p align="center">
  <img src="https://img.shields.io/badge/Cloud-0078D4?style=for-the-badge&logo=cloud"/>
  <img src="https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white"/>
  <img src="https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white"/>
  <img src="https://img.shields.io/badge/IaC-8A2BE2?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white"/>
  <img src="https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white"/>
  <img src="https://img.shields.io/badge/DevSecOps-E84D1C?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Contributions-Welcome-blue?style=for-the-badge"/>
</p>

# 📘 Workshop DevOps Multi-Nube E2E (AWS-Azure) con Terraform y Ansible

## 🎯 1. Descripción y Objetivos

Este repositorio contiene el código y la documentación de un workshop práctico de DevOps/SRE. El objetivo es desplegar una arquitectura multi-nube en AWS y Azure de forma simultánea, gestionada al 100% como Infraestructura como Código (IaC).

Utilizamos Terraform para desplegar la infraestructura de red y cómputo, y Ansible para la configuración automatizada de las máquinas virtuales.

**Objetivos Clave del Taller:**
- Multi-Nube Real: Desplegar recursos en AWS y Azure en un solo apply.
- Dependencia Multi-Nube: Demostrar cómo un recurso en una nube (ej. firewall de AWS) puede depender de un recurso en otra nube (ej. IP de Azure).
- Mejores Prácticas SRE: Implementar un backend remoto (en Azure Storage) para la gestión segura y colaborativa del estado (.tfstate), con un ciclo de vida 100% independiente de la infraestructura.
- Configuración (DevOps): Usar Ansible para instalar node_exporter en ambas VMs, ejecutado automáticamente por Terraform.
- FinOps: Usar scripts deploy y destroy para un control de costos estricto, y documentar el proceso de limpieza total.
- Depuración Realista: Exponer y documentar errores comunes (Firewalls, Sintaxis, Asimetría de Nubes) como parte del proceso de aprendizaje.

---

## 🏗️ 2. Arquitectura de la Solución

1. **Backend (Azure):** Resource Group separado (rg-wstfstate-backend) con Storage Account (stwstfstate...) que almacena terraform.tfstate con versionado y cifrado.  
2. **Infraestructura AWS (VPC):** 1 VPC, 1 Subnet Pública, 1 Internet Gateway, 1 Tabla de Rutas, 1 Instancia EC2 (Ubuntu 20.04), 1 Security Group.  
3. **Infraestructura Azure (VNet):** 1 Resource Group (rg-workshop-multicloud-dev), 1 VNet, 1 Subnet, 1 VM Linux (Ubuntu 20.04) con IP Pública y NIC, 1 NSG.  
4. **Conexión Multi-Nube:** AWS permite puerto 9100 solo desde IP de Azure y local. Azure permite puerto 9100 solo desde IP de AWS y local.  
5. **Configuración (Ansible):** Terraform genera inventario (generated_inventory.ini) y ejecuta ansible-playbook para instalar node_exporter.

---

## 🚀 3. Guía de Ejecución (How-To)

### 🔧 Prerrequisitos
Instala en tu máquina local:
- terraform (v1.13.x+)
- ansible (v2.16.x+)
- aws-cli
- az-cli
- Claves SSH (ej. ~/.ssh/id_rsa.pub)

### 🔐 Paso 1: Autenticación
aws configure  
az login  
az account list --output table  
az account set --subscription "Tu-Subscription-ID-o-Nombre"

### 📦 Paso 2: Crear el Backend
export LOCATION="eastus"  
export BASE_NAME="wstfstate$(date +%s | tail -c 4)"  
echo "Tu BASE_NAME es: $BASE_NAME"  
./scripts/backend_bootstrap/azure/create_backend_azure.sh  
Output: anota Resource Group y Storage Account

### ⚙️ Paso 3: Configurar Terraform
Editar terraform_infra/main.tf → descomentar backend "azurerm"  
Rellenar nombres del Resource Group y Storage Account  
cp terraform_infra/terraform.tfvars.example terraform_infra/terraform.tfvars  
Asegúrate de que admin_public_key_path apunte a tu clave .pub

### 🚀 Paso 4: Desplegar la Infraestructura
./scripts/infra_deployment/deploy_infra.sh  
Ejecuta init, validate, plan y apply  
Terraform desplegará los recursos y luego ejecutará Ansible

### ✅ Paso 5: Validación (Smoke Test)
curl http://<IP_AWS>:9100/metrics  
curl http://<IP_AZURE>:9100/metrics  
ssh ubuntu@<IP_AWS>  
ssh gmt@<IP_AZURE>

---

## 🧹 4. Guía de Destrucción (FinOps)

CRÍTICO: Sigue estos pasos para eliminar todos los recursos y evitar costos.

### Paso 1: Destruir Infraestructura  
./scripts/infra_deployment/destroy_infra.sh  
Escribe 'destruir' para confirmar  
Resultado: Destroy complete! Resources: 18 destroyed

### Paso 2: Destruir Backend  
export BASE_NAME="wstfstate..."  
./scripts/backend_bootstrap/azure/destroy_backend_azure.sh  
Escribe 'destruir' para confirmar  
Resultado: --- Backend Azure Destruido ---

---

## 💡 5. Lecciones Aprendidas

1. Sintaxis de Proveedor (AWS vs Azure): default_tags en azurerm causó conflicto. Solución: etiquetado por recurso.  
2. Nomenclatura (AWS): Prefijo sg- reservado. Solución: renombrar a workshop-vm-sg.  
3. Sintaxis de Ansible: listen no válido en tasks. Solución: mover a handlers/main.yml.  
4. Asimetría de Nube (Usuarios): Azure usa gmt, AWS usa ubuntu. Solución: ajustar ansible_user.  
5. Sintaxis de Proveedor (CIDR): aws_security_group requiere /32. Solución: añadir sufijo /32 en ingress.  
6. Firewall (Validación): curl falló con timeout. Solución: añadir IP local en reglas ingress.

---

## 🖼️ Diagrama de Arquitectura (ASCII)

                 ┌───────────────────────────┐
                 │        Azure Cloud        │
                 │   ┌───────────────────┐   │
                 │   │ Resource Group    │   │
                 │   │ VNet + Subnet     │   │
                 │   │ NSG (Firewall)    │   │
                 │   │ VM Linux (gmt)    │   │
                 │   │ Node Exporter :9100 │ │
                 │   └───────────────────┘   │
                 └───────────────────────────┘
                           ▲
                           │ Comunicación segura (puerto 9100)
                           ▼
                 ┌───────────────────────────┐
                 │         AWS Cloud         │
                 │   ┌───────────────────┐   │
                 │   │ VPC + Subnet      │   │
                 │   │ Route Table       │   │
                 │   │ Security Group    │   │
                 │   │ EC2 Linux (ubuntu)│   │
                 │   │ Node Exporter :9100 │ │
                 │   └───────────────────┘   │
                 └───────────────────────────┘

---

## 📞 Contacto y Comunidad

- 💼 LinkedIn: [linkedin.com/in/jgaragorry](https://www.linkedin.com/in/jgaragorry)  
- 🎥 YouTube: [youtube.com/@jgaragorry](https://www.youtube.com/@Softraincorp)  
- 🎵 TikTok: [tiktok.com/@jgaragorry](https://www.tiktok.com/@softtraincorp)  
- 📸 Instagram: [instagram.com/jgaragorry](https://www.instagram.com/stclatam/)  
- 💬 Comunidad WhatsApp: (https://chat.whatsapp.com/ENuRMnZ38fv1pk0mHlSixa)

---

✍️ **Autor:** José Garagorry  
🔗 **Repo principal:** MultiCloud-DevOps-E2E-A
