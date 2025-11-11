resource "azurerm_resource_group" "main" {
  name     = var.azure_rg_name
  location = var.azure_location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-workshop"
  address_space       = [var.azure_vnet_cidr]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "snet-workshop"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.azure_subnet_cidr]
}
