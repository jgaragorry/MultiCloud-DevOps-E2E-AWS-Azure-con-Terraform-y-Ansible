# --- Variables Generales y de FinOps ---
variable "common_tags" {
  description = "Tags a aplicar a todos los recursos para FinOps."
  type        = map(string)
  default = {
    project   = "workshop-multicloud"
    owner     = "gmt"
    env       = "development"
    objective = "training"
  }
}

variable "admin_public_key_path" {
  description = "Ruta a la clave pública SSH del administrador (ej. /home/gmt/.ssh/id_rsa.pub)"
  type        = string
}

variable "admin_username" {
  description = "Nombre de usuario administrador para las VMs"
  type        = string
  default     = "gmt"
}

# --- Variables Específicas de AWS ---
variable "aws_region" {
  description = "Región de AWS para el despliegue."
  type        = string
  default     = "us-east-1"
}

variable "aws_vm_instance_type" {
  description = "Tipo de instancia EC2 (Free Tier eligible)."
  type        = string
  default     = "t2.micro"
}

# --- ¡NUEVA VARIABLE! ---
variable "aws_monitoring_vm_instance_type" {
  description = "Tipo de instancia EC2 para la VM de Monitoreo (Grafana/Prometheus)."
  type        = string
  default     = "t3.small" # Necesita más RAM que t2.micro
}

variable "aws_vpc_cidr" {
  description = "Bloque CIDR para la VPC de AWS."
  type        = string
  default     = "10.10.0.0/16"
}

variable "aws_subnet_cidr" {
  description = "Bloque CIDR para la Subnet pública de AWS."
  type        = string
  default     = "10.10.1.0/24"
}


# --- Variables Específicas de Azure ---
variable "azure_location" {
  description = "Localización de Azure para el despliegue."
  type        = string
  default     = "eastus"
}

variable "azure_vm_size" {
  description = "Tamaño de la VM de Azure (Free Tier eligible)."
  type        = string
  default     = "Standard_B1s"
}

variable "azure_rg_name" {
  description = "Nombre del Resource Group para la infraestructura del workshop."
  type        = string
  default     = "rg-workshop-multicloud-dev"
}

variable "azure_vnet_cidr" {
  description = "Bloque CIDR para la VNet de Azure."
  type        = string
  default     = "10.20.0.0/16"
}

variable "azure_subnet_cidr" {
  description = "Bloque CIDR para la Subnet de Azure."
  type        = string
  default     = "10.20.1.0/24"
}
