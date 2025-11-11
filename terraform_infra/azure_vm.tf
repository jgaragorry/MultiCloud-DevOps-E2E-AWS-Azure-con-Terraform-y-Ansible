# 1. IP Pública para la VM de Azure
resource "azurerm_public_ip" "main" {
  name                = "pip-workshop"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 2. Network Security Group (NSG - Firewall)
resource "azurerm_network_security_group" "main" {
  name                = "nsg-workshop"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Regla 1: Permitir SSH (puerto 22) solo desde nuestra IP
  security_rule {
    name                       = "AllowSSHFromMyIP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = data.http.my_ip.response_body
    destination_address_prefix = "*"
  }

  # Regla 2: Permitir Node Exporter (puerto 9100)
  security_rule {
    name                       = "AllowNodeExporter"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9100"
    # --- ¡ESTA ES LA CORRECCIÓN CLAVE! ---
    # Permite a Prometheus (VM de Monitoreo) y a ti (Local)
    source_address_prefixes = [
      "${aws_instance.monitoring.public_ip}/32", # Desde la VM de Monitoreo (IP Pública)
      "${data.http.my_ip.response_body}/32"      # Desde nuestra IP local
    ]
    destination_address_prefix = "*"
  }
}

# 3. Network Interface (NIC)
resource "azurerm_network_interface" "main" {
  name                = "nic-workshop"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# 4. Asociar el NSG con la NIC
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# 5. Crear la Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-workshop-azure"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.azure_vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.main.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
