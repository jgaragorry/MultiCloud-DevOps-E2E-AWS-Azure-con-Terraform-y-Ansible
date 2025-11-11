# 🚀 Guía Rápida del Workshop MultiCloud DevOps (AWS + Azure) con Observabilidad

Este documento es una **guía simplificada** para estudiantes que quieran reproducir el workshop.  
Aquí encontrarás el **alcance**, los **prerrequisitos**, un **checklist paso a paso**, las **validaciones finales**, el **diagrama ASCII de arquitectura**, las **lecciones aprendidas** y la **sección de contacto y comunidad**.

---

## 🎯 Alcance del Workshop

Al finalizar este workshop habrás aprendido a:

- Desplegar infraestructura en **AWS** y **Azure** de forma simultánea con **Terraform**.  
- Configurar automáticamente las VMs con **Ansible** (instalación de Node Exporter).  
- Desplegar una **pila de observabilidad** con **Prometheus + Grafana** en una VM dedicada.  
- Validar métricas en Prometheus y dashboards en Grafana.  
- Usar un **backend remoto** para manejar el estado de Terraform en Azure Storage.  
- Aplicar buenas prácticas de **FinOps**: etiquetado, trazabilidad y destrucción segura.  
- Documentar y resolver errores comunes en entornos multi-nube.

**Resultado esperado:**  
Dos VMs (una en AWS y otra en Azure) con Node Exporter corriendo en el puerto `9100`, monitoreadas por Prometheus y Grafana en una VM de AWS, y la capacidad de destruir todo sin dejar costos residuales.

---

## 🔧 Prerrequisitos

Instala en tu máquina local:

- Terraform (v1.13.x+)  
- Ansible (v2.16.x+)  
- AWS CLI  
- Azure CLI  
- Claves SSH (ejemplo: `~/.ssh/id_rsa` y `~/.ssh/id_rsa.pub`)

---

## ✅ Checklist Paso a Paso

### 1. Autenticación
- [ ] Configurar credenciales en AWS → `aws configure`  
- [ ] Iniciar sesión en Azure → `az login`  
- [ ] Seleccionar suscripción → `az account set --subscription "<ID-o-Nombre>"`

### 2. Crear el Backend (Azure)
- [ ] Definir variables:  
  `export LOCATION="eastus"`  
  `export BASE_NAME="wstfstate-obs-$(date +%s | tail -c 4)"`  
- [ ] Ejecutar script:  
  `./scripts/backend_bootstrap/azure/create_backend_azure.sh`  
- [ ] Guardar nombres de Resource Group y Storage Account.

### 3. Configurar Terraform
- [ ] Editar `terraform_infra/main.tf` → descomentar backend "azurerm".  
- [ ] Rellenar nombres de RG y Storage Account.  
- [ ] Crear `terraform.tfvars`:  
  `cp terraform_infra/terraform.tfvars.example terraform_infra/terraform.tfvars`  
- [ ] Editar `variables.tf` → `admin_public_key_path` debe apuntar a tu clave privada (`id_rsa`).

### 4. Desplegar Infraestructura y Observabilidad
- [ ] Ejecutar:  
  `./scripts/infra_deployment/deploy_infra.sh`  
- [ ] Confirmar que Terraform despliega recursos y Ansible configura las 3 VMs (AWS target, Azure target, VM de monitoreo).

### 5. Validación
- [ ] Prometheus: abrir `http://<IP_MONITORING>:9090` → Status -> Targets → 2/2 UP.  
- [ ] Grafana: abrir `http://<IP_MONITORING>:3000` → admin/admin → Data Sources y Dashboard “Node Exporter Full” listos.  
- [ ] Conexión SSH:  
  `ssh ubuntu@<IP_AWS>`  
  `ssh gmt@<IP_AZURE>`

---

## 🧹 Destrucción Segura (FinOps)

- [ ] Destruir infraestructura:  
  `./scripts/infra_deployment/destroy_infra.sh`  
  Confirmar escribiendo `destruir`.  

- [ ] Destruir backend (opcional):  
  `export BASE_NAME="wstfstate-obs-..."`  
  `./scripts/backend_bootstrap/azure/destroy_backend_azure.sh`  
  Confirmar escribiendo `destruir`.

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

## 💡 Lecciones Clave de Depuración

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

## 📞 Contacto y Comunidad

- 💼 LinkedIn: [linkedin.com/in/jgaragorry](https://www.linkedin.com/in/jgaragorry)  
- 🎥 YouTube: [youtube.com/@Softraincorp](https://www.youtube.com/@Softraincorp)  
- 🎵 TikTok: [tiktok.com/@softtraincorp](https://www.tiktok.com/@softtraincorp)  
- 📸 Instagram: [instagram.com/stclatam](https://www.instagram.com/stclatam/)  
- 💬 Comunidad WhatsApp: [Unirse al grupo](https://chat.whatsapp.com/ENuRMnZ38fv1pk0mHlSixa)

---

✍️ **Autor:** José Garagorry  
🔗 **Repo principal:** MultiCloud-DevOps-E2E-AWS-Azure-con-Terraform-y-Ansible  
📜 **Licencia:** MIT

