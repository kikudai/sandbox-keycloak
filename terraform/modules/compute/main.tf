data "aws_ami" "amazon_linux" {
  # 必要に応じて書き換えて下さい (ARM 用 / x86 用 など)
  most_recent = true
  owners      = ["137112412989"] # Amazon のオーナーID
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
  description = "EC2 security group for Keycloak container"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]  # ALB など同一 VPC 内からのアクセスを許可
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
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # システム更新 & Docker のインストール
    yum update -y
    yum install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    # Docker Compose のインストール
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # docker-compose.yml 作成
    cat <<EOL > /home/ec2-user/docker-compose.yml
    version: '3'
    services:
      keycloak:
        image: keycloak/keycloak:latest
        container_name: keycloak
        environment:
          - KC_BOOTSTRAP_ADMIN_USERNAME=${var.keycloak_admin}
          - KC_BOOTSTRAP_ADMIN_PASSWORD=${var.keycloak_admin_password}
          - KC_HOSTNAME=https://keycloak.kikudai.work
          - KC_HOSTNAME_DEBUG=true
          - KC_LOG_LEVEL=debug
        ports:
          - "80:8080"
        command:
          - start-dev
    EOL

    # ファイル所有者を ec2-user に変更
    chown ec2-user:ec2-user /home/ec2-user/docker-compose.yml

    # ec2-user 権限で docker-compose up
    cd /home/ec2-user
    sudo -u ec2-user docker-compose up -d
  EOF

  tags = {
    Name = "Keycloak-EC2"
  }
}
