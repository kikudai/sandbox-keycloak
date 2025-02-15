data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.*-kernel-6.1-arm64"]

  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "keycloak-ec2-sg"
  description = "EC2 用セキュリティグループ（Keycloak コンテナ用）"
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
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t4g.micro"  # ARM 用インスタンス
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
set -ex
dnf update -y
dnf install -y docker
systemctl enable --now docker
usermod -a -G docker ec2-user
# Keycloak コンテナをホストの 80 番ポートにマッピング（内部では 8080 で動作）
docker run -d --name keycloak -p 80:8080 quay.io/keycloak/keycloak:17.0.1 start-dev
EOF

  tags = {
    Name = "Keycloak-EC2"
  }
}
