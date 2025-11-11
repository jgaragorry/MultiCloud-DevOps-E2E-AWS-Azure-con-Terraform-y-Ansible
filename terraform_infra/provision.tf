# 1. Generar el archivo de inventario dinámicamente
resource "local_file" "ansible_inventory" {

  content = templatefile("../ansible_config/inventory.tpl", {
    # --- ¡ESTA ES LA CORRECCIÓN FINAL! ---
    aws_target_public_ip  = aws_instance.main.public_ip
    aws_target_private_ip = aws_instance.main.private_ip
    azure_target_public_ip  = azurerm_public_ip.main.ip_address
    monitoring_public_ip  = aws_instance.monitoring.public_ip
    
    gmt_user           = var.admin_username
    ubuntu_user        = "ubuntu" 
  })

  filename = "../ansible_config/generated_inventory.ini"
}

# 2. Ejecutar Ansible (Provisioner)
resource "null_resource" "run_ansible" {

  # El bloque 'triggers' asegura que Ansible se
  # re-ejecute si CUALQUIER archivo de Ansible cambia.
  triggers = {
    inventory_template_hash   = filemd5("../ansible_config/inventory.tpl")
    playbook_hash             = filemd5("../ansible_config/playbook_site.yml")
    prometheus_config_hash    = filemd5("../ansible_config/roles/prometheus/templates/prometheus.yml.j2")
    prometheus_service_hash   = filemd5("../ansible_config/roles/prometheus/templates/prometheus.service.j2")
    grafana_datasource_hash   = filemd5("../ansible_config/roles/grafana/templates/datasource-prometheus.yml.j2")
  }

  depends_on = [
    aws_instance.main,
    azurerm_linux_virtual_machine.main,
    aws_instance.monitoring,
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    
    # Llamamos al nuevo playbook "site.yml"
    command = "ansible-playbook -i generated_inventory.ini playbook_site.yml"
    
    working_dir = "../ansible_config/"
  }
}
