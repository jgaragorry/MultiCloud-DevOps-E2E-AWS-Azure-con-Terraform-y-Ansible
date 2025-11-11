terraform {
  required_version = "~> 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }

  # --- CONFIGURACIÓN DEL BACKEND ---
  # Apuntando al backend que acabas de crear
  backend "azurerm" {
    resource_group_name  = "rg-wstfstate149-backend"
    storage_account_name = "stwstfstate14913903"
    container_name       = "tfstate"
    key                  = "multicloud-obs/terraform.tfstate"
  }
}

# --- Configuración de Providers ---
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

provider "azurerm" {
  features {}
}

# --- Data Sources ---
data "http" "my_ip" {
  url = "https://api.ipify.org"
}
