[targets]
# Ansible se conecta a ${aws_target_public_ip}, pero usaremos ${aws_target_private_ip} para el scrapeo
${aws_target_public_ip} ansible_user=${ubuntu_user} scrape_ip=${aws_target_private_ip}

# Ansible se conecta a ${azure_target_public_ip} y la usa también para el scrapeo
${azure_target_public_ip} ansible_user=${gmt_user} scrape_ip=${azure_target_public_ip}

[monitoring_server]
${monitoring_public_ip} ansible_user=${ubuntu_user}

[all:vars]
ansible_python_interpreter = /usr/bin/python3
ansible_ssh_common_args = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
