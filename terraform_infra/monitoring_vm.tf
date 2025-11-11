# 1. Clave SSH para la VM de Monitoreo
resource "aws_key_pair" "monitoring" {
  key_name   = "workshop-key-monitoring"
  public_key = file(var.admin_public_key_path)
}

# 2. Security Group (Firewall) para la VM de Monitoreo
resource "aws_security_group" "monitoring" {
  name        = "monitoring-sg"
  description = "Allow SSH, Prometheus, and Grafana from my IP"
  vpc_id      = aws_vpc.main.id # Se despliega en la misma VPC

  # Regla 1: Permitir SSH (puerto 22) desde nuestra IP
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.response_body}/32"]
  }

  # Regla 2: Permitir Prometheus (puerto 9090) desde nuestra IP
  ingress {
    description = "Prometheus from my IP"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.response_body}/32"]
  }

  # Regla 3: Permitir Grafana (puerto 3000) desde nuestra IP
  ingress {
    description = "Grafana from my IP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.response_body}/32"]
  }

  # Regla 4: Permitir todo el tráfico de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Crear la Instancia EC2 de Monitoreo
resource "aws_instance" "monitoring" {
  ami                         = data.aws_ami.ubuntu.id # Reutiliza la AMI de Ubuntu
  instance_type               = var.aws_monitoring_vm_instance_type
  subnet_id                   = aws_subnet.public.id # Reutiliza la Subnet pública
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  key_name                    = aws_key_pair.monitoring.key_name
  associate_public_ip_address = true

  tags = {
    Name = "monitoring-server-tf"
  }
  
  depends_on = [aws_key_pair.monitoring]
}
