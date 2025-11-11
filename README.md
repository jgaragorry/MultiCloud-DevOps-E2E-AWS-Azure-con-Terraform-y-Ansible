<p align="center">
  <img src="https://img.shields.io/badge/Cloud-0078D4?style=for-the-badge&logo=cloud"/>
  <img src="https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white"/>
  <img src="https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white"/>
  <img src="https://img.shields.io/badge/IaC-8A2BE2?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white"/>
  <img src="https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white"/>
  <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white"/>
  <img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Contributions-Welcome-blue?style=for-the-badge"/>
</p>

# 📘 Workshop SRE: Pila de Observabilidad Multi-Nube (AWS-Azure)

## 🎯 1. Descripción y Objetivos

Este repositorio contiene el código y la documentación de un workshop práctico de nivel avanzado de SRE/DevOps. El objetivo es desplegar una arquitectura multi-nube robusta y **auto-monitoreada** en AWS y Azure, gestionada 100% como Infraestructura como Código (IaC).

Este proyecto va más allá de un simple despliegue; se enfoca en la **depuración realista** y la implementación de una pila de **Observabilidad** completa (`Prometheus` + `Grafana`) que se auto-configura.

**Objetivos Clave del Taller:**
- Multi-Nube Real: Desplegar recursos en AWS y Azure en un solo apply.
- Backend remoto seguro en Azure Storage para el estado de Terraform.
- Pila de Observabilidad: Prometheus + Grafana en VM dedicada.
- Auto-configuración con Ansible: Node Exporter en targets, Prometheus configurado automáticamente, Grafana con dashboard listo.
- Depuración realista: documentar y resolver errores comunes.

---

## 🏗️ 2. Arquitectura de la Solución

1. **Backend (Azure):** Resource Group separado (`rg-wstfstate-backend`) con Storage Account (`stwstfstate...`) que almacena terraform.tfstate.  
2. **Infraestructura Target AWS:** VPC, Subnet pública, IGW, Tabla de rutas, EC2 Ubuntu 20.04, SG `workshop-vm-sg`.  
3. **Infraestructura Target Azure:** Resource Group `rg-workshop-multicloud-dev`, VNet, Subnet, VM Ubuntu 20.04, NSG `nsg-workshop`.  
4. **Infraestructura de Monitoreo (AWS):** EC2 Ubuntu 20.04 (`t3.small`) con SG `monitoring-sg` que permite puertos 22, 3000 (Grafana), 9090 (Prometheus).  
5. **Lógica de Red:** Targets permiten puerto 9100 solo desde VM de monitoreo y la IP local. AWS usa IP privada, Azure IP pública.  
6. **Configuración (Ansible):** Terraform genera `inventory.ini` con 3 hosts (`aws_target`, `azure_target`, `monitoring_server`). Prometheus se configura para scrapear IP privada de AWS y pública de Azure.

---

## 🚀 3. Guía de Ejecución

### Prerrequisitos
- terraform (v1.13.x+)  
- ansible (v2.16.x+)  
- aws-cli  
- az-cli  
- Claves SSH (`~/.ssh/id_rsa` y `~/.ssh/id_rsa.pub`)

### Paso 1: Autenticación
aws configure  
az login  
az account list --output table  
az account set --subscription "Tu-Subscription-ID-o-Nombre"

### Paso 2: Crear Backend
export LOCATION="eastus"  
export BASE_NAME="wstfstate-obs-$(date +%s | tail -c 4)"  
echo "Tu BASE_NAME es: $BASE_NAME"  
./scripts/backend_bootstrap/azure/create_backend_azure.sh  

### Paso 3: Configurar Terraform
Editar `terraform_infra/main.tf` → descomentar backend "azurerm".  
Rellenar RG y Storage Account.  
cp terraform_infra/terraform.tfvars.example terraform_infra/terraform.tfvars  
Editar `variables.tf` → `admin_public_key_path` debe apuntar a tu clave privada (`id_rsa`).

### Paso 4: Desplegar Pila Completa
./scripts/infra_deployment/deploy_infra.sh  
Terraform desplegará 21 recursos y Ansible configurará las 3 VMs.

### Paso 5: Validación
- Prometheus: http://<IP_MONITORING>:9090 → Status -> Targets → 2/2 UP.  
- Grafana: http://<IP_MONITORING>:3000 → admin/admin → Data Sources y Dashboard “Node Exporter Full” listos.

---

## 🧹 4. Guía de Destrucción (FinOps)

./scripts/infra_deployment/destroy_infra.sh  
Confirmar escribiendo `destruir`.  
Resultado: 21 recursos destruidos.  

Opcional: destruir backend si no se usará más.  
export BASE_NAME="wstfstate-obs-..."  
./scripts/backend_bootstrap/azure/destroy_backend_azure.sh  
Confirmar escribiendo `destruir`.

---

## 💡 5. Lecciones Aprendidas

1. Condición de carrera (SSH): Terraform debe esperar a que sshd esté activo antes de Ansible.  
2. Punto ciego de Terraform: triggers en null_resource para detectar cambios en archivos Ansible.  
3. Lógica de red: Ansible usa IP pública, Prometheus IP privada.  
4. Firewalls: targets deben permitir IP de VM de monitoreo.  
5. Prometheus: escuchar en 0.0.0.0:9090.  
6. Configuración corrupta: corregir template prometheus.yml.  
7. Asimetría de usuarios: AWS usa `ubuntu`, Azure `gmt`.  
8. CIDR: AWS requiere /32.  
9. Sintaxis Ansible: handlers separados de tasks.  
10. Nomenclatura AWS: prefijo sg- reservado.

---

## 🖼️ Diagrama de Arquitectura (ASCII)

                 ┌───────────────────────────┐
                 │        Azure Cloud        │
                 │   ┌───────────────────┐   │
                 │   │ VM Target (gmt)   │   │
                 │   │ Node Exporter :9100 │ │
                 │   └───────────────────┘   │
                 └───────────────────────────┘
                           ▲
                           │ Comunicación segura (9100)
                           ▼
                 ┌───────────────────────────┐
                 │         AWS Cloud         │
                 │   ┌───────────────────┐   │
                 │   │ VM Target (ubuntu)│   │
                 │   │ Node Exporter :9100 │ │
                 │   └───────────────────┘   │
                 │   ┌───────────────────┐   │
                 │   │ VM Monitoreo      │   │
                 │   │ Prometheus :9090  │   │
                 │   │ Grafana :3000     │   │
                 │   └───────────────────┘   │
                 └───────────────────────────┘

---

## 📞 Contacto y Comunidad

- 💼 LinkedIn: [linkedin.com/in/jgaragorry](https://www.linkedin.com/in/jgaragorry)  
- 🎥 YouTube: [youtube.com/@Softraincorp](https://www.youtube.com/@Softraincorp)  
- 🎵 TikTok: [tiktok.com/@softtraincorp](https://www.tiktok.com/@softtraincorp)  
- 📸 Instagram: [instagram.com/stclatam](https://www.instagram.com/stclatam/)  
- 💬 Comunidad WhatsApp: [Unirse al grupo](https://chat.whatsapp.com/ENuRMnZ38fv1pk0mHlSixa)

---

✍️ **Autor:** José Garagorry  
🔗 **Repo principal:** MultiCloud-DevOps-E2E-AWS-Azure-con-Terraform-y-Ansible  
📜 **
