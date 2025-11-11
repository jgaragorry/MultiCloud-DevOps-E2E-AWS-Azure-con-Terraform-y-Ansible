resource "aws_security_group" "vm" {
  name        = "workshop-vm-sg" # Corregido (sin prefijo sg-)
  description = "Allow SSH and Node Exporter"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.response_body}/32"] # Corregido (con /32)
  }

  ingress {
    description = "Node Exporter from Monitoring VM and Local"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    # --- ¡ESTA ES LA CORRECCIÓN CLAVE! ---
    # Permite a Prometheus (VM de Monitoreo) y a ti (Local)
    cidr_blocks = [
      "${aws_instance.monitoring.private_ip}/32", # Desde la VM de Monitoreo (IP Privada)
      "${data.http.my_ip.response_body}/32"      # Desde nuestra IP local
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "admin" {
  key_name   = "workshop-key-aws"
  public_key = file(var.admin_public_key_path)
}

resource "aws_instance" "main" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.aws_vm_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.vm.id]
  key_name                    = aws_key_pair.admin.key_name
  associate_public_ip_address = true
  
  depends_on = [aws_key_pair.admin]
}
