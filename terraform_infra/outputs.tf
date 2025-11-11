output "aws_target_public_ip" {
  description = "IP Pública de la instancia EC2 objetivo en AWS."
  value       = aws_instance.main.public_ip
}

output "azure_target_public_ip" {
  description = "IP Pública de la VM objetivo en Azure."
  value       = azurerm_public_ip.main.ip_address
}

# --- ¡NUEVO! ---
output "monitoring_server_public_ip" {
  description = "IP Pública del servidor de Monitoreo (Prometheus/Grafana)."
  value       = aws_instance.monitoring.public_ip
}

output "ssh_command_aws_target" {
  description = "Comando para conectar por SSH a la VM objetivo de AWS."
  value       = "ssh ubuntu@${aws_instance.main.public_ip}"
}

output "ssh_command_azure_target" {
  description = "Comando para conectar por SSH a la VM objetivo de Azure."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

# --- ¡NUEVO! ---
output "ssh_command_monitoring_server" {
  description = "Comando para conectar por SSH al servidor de Monitoreo."
  value       = "ssh ubuntu@${aws_instance.monitoring.public_ip}"
}

output "node_exporter_aws_url" {
  description = "URL para verificar Node Exporter en AWS."
  value       = "http://${aws_instance.main.public_ip}:9100/metrics"
}

output "node_exporter_azure_url" {
  description = "URL para verificar Node Exporter en Azure."
  value       = "http://${azurerm_public_ip.main.ip_address}:9100/metrics"
}

# --- ¡NUEVO! ---
output "prometheus_url" {
  description = "URL para acceder a la interfaz de Prometheus."
  value       = "http://${aws_instance.monitoring.public_ip}:9090"
}

# --- ¡NUEVO! ---
output "grafana_url" {
  description = "URL para acceder a la interfaz de Grafana. (user: admin, pass: admin)"
  value       = "http://${aws_instance.monitoring.public_ip}:3000"
}
