# 🚀 Guía Rápida del Workshop MultiCloud DevOps (AWS + Azure)

Este documento es una **guía simplificada** para estudiantes que quieran reproducir el workshop.  
Aquí encontrarás el **alcance**, los **prerrequisitos**, un **checklist paso a paso**, las **validaciones finales**, el **diagrama ASCII de arquitectura** y la **sección de contacto y comunidad**.

---

## 🎯 Alcance del Workshop

Al finalizar este workshop habrás aprendido a:

- Desplegar infraestructura en **AWS** y **Azure** de forma simultánea con **Terraform**.  
- Configurar automáticamente las VMs con **Ansible** (instalación de Node Exporter).  
- Usar un **backend remoto** para manejar el estado de Terraform en Azure Storage.  
- Aplicar buenas prácticas de **FinOps**: etiquetado, trazabilidad y destrucción segura.  
- Validar la **observabilidad básica** con Node Exporter en ambas nubes.  
- Documentar y resolver errores comunes en entornos multi-nube.

**Resultado esperado:**  
Dos VMs (una en AWS y otra en Azure) con Node Exporter corriendo en el puerto `9100`, listas para ser monitoreadas, y la capacidad de destruir todo sin dejar costos residuales.

---

## 🔧 Prerrequisitos

Instala en tu máquina local:

- Terraform (v1.13.x+)  
- Ansible (v2.16.x+)  
- AWS CLI  
- Azure CLI  
- Claves SSH (ejemplo: `~/.ssh/id_rsa.pub`)

---

## ✅ Checklist Paso a Paso

### 1. Autenticación
- [ ] Configurar credenciales en AWS → `aws configure`  
- [ ] Iniciar sesión en Azure → `az login`  
- [ ] Seleccionar suscripción → `az account set --subscription "<ID-o-Nombre>"`

### 2. Crear el Backend (Azure)
- [ ] Definir variables:  
  `export LOCATION="eastus"`  
  `export BASE_NAME="wstfstate$(date +%s | tail -c 4)"`  
- [ ] Ejecutar script:  
  `./scripts/backend_bootstrap/azure/create_backend_azure.sh`  
- [ ] Guardar nombres de Resource Group y Storage Account.

### 3. Configurar Terraform
- [ ] Editar `terraform_infra/main.tf` → descomentar backend "azurerm".  
- [ ] Rellenar nombres de RG y Storage Account.  
- [ ] Crear `terraform.tfvars`:  
  `cp terraform_infra/terraform.tfvars.example terraform_infra/terraform.tfvars`  
- [ ] Verificar que `admin_public_key_path` apunte a tu clave SSH pública.

### 4. Desplegar Infraestructura
- [ ] Ejecutar:  
  `./scripts/infra_deployment/deploy_infra.sh`  
- [ ] Confirmar que Terraform despliega recursos y Ansible instala Node Exporter.

### 5. Validación
- [ ] Probar métricas en AWS:  
  `curl http://<IP_AWS>:9100/metrics`  
- [ ] Probar métricas en Azure:  
  `curl http://<IP_AZURE>:9100/metrics`  
- [ ] Conexión SSH:  
  `ssh ubuntu@<IP_AWS>`  
  `ssh gmt@<IP_AZURE>`

---

## 🧹 Destrucción Segura (FinOps)

- [ ] Destruir infraestructura:  
  `./scripts/infra_deployment/destroy_infra.sh`  
  Confirmar escribiendo `destruir`.  

- [ ] Destruir backend:  
  `export BASE_NAME="wstfstate..."`  
  `./scripts/backend_bootstrap/azure/destroy_backend_azure.sh`  
  Confirmar escribiendo `destruir`.

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

## 💡 Preguntas Frecuentes

- **¿Qué usuario usar para SSH?**  
  - AWS: `ubuntu`  
  - Azure: `gmt` (o el definido en tu tfvars)

- **¿Por qué falla el curl al puerto 9100?**  
  - Revisa reglas de firewall: asegúrate de incluir tu IP local.

- **¿Por qué no se borra el bucket de S3?**  
  - Si tiene versionado, elimina versiones y delete markers antes de destruir.

---

## 📚 Lecciones Clave

1. Diferencias de sintaxis entre proveedores (AWS vs Azure).  
2. Nomenclatura reservada en AWS (`sg-`).  
3. Handlers en Ansible deben ir en `handlers/main.yml`.  
4. Usuarios distintos en VMs (ubuntu vs gmt).  
5. Reglas de AWS requieren `/32` en CIDR.  
6. Siempre incluir tu IP local en reglas de firewall para validación.

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

