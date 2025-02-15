resource "aws_security_group" "ec2_sg" {
  name        = "keycloak-ec2-sg"
  description = "EC2 security group for Keycloak container"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]  # VPC 内からの ALB 経由のアクセスを許可
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "keycloak" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Docker と Docker Compose のインストール
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker ec2-user

    # Docker Compose のインストール
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # `docker-compose.yml` を配置
    cat <<EOL > /home/ec2-user/docker-compose.yml
    version: '3.8'
    services:
      keycloak:
        image: keycloak/keycloak:latest
        container_name: keycloak
        environment:
          - KEYCLOAK_ADMIN=${var.keycloak_admin}
          - KEYCLOAK_ADMIN_PASSWORD=${var.keycloak_admin_password}
        ports:
          - "8080:8080"
        command:
          - start-dev
    EOL

    # docker-compose の実行
    cd /home/ec2-user
    sudo chown ec2-user:ec2-user docker-compose.yml
    sudo -u ec2-user docker-compose up -d
  EOF

  tags = {
    Name = "Keycloak-EC2"
  }
}
