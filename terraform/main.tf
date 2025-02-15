provider "aws" {
  region = "ap-northeast-1"  # 必要に応じて変更
}

# デフォルトVPCとサブネットの取得
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "default" {
  id = data.aws_subnet_ids.default.ids[0]
}

# Amazon Linux 2 の最新AMIを取得
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"]  # Amazon公式AMI
}

# セキュリティグループの作成
resource "aws_security_group" "keycloak_sg" {
  name        = "keycloak-sg"
  description = "Keycloak用のセキュリティグループ"
  vpc_id      = data.aws_vpc.default.id

  # HTTP (80番ポート) を全世界から許可
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (22番ポート) ※管理用。ご自身のIPに変更してください
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2インスタンスの作成
resource "aws_instance" "keycloak" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"  # Free Tier対象
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.keycloak_sg.id]
  key_name               = var.key_name  # SSH接続用のキーペア名（事前作成済み）

  associate_public_ip_address = true

  # EC2起動時にDockerをインストールし、Keycloakコンテナを起動するUser Data
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -a -G docker ec2-user
    # Keycloak公式コンテナを起動（ホストの80番ポート → コンテナの8080番ポートにマッピング）
    docker run -d --name keycloak -p 80:8080 quay.io/keycloak/keycloak:17.0.1 start-dev
  EOF

  tags = {
    Name = "Keycloak-EC2"
  }
}

# Elastic IP の割り当て（固定のパブリックIPを確保）
resource "aws_eip" "keycloak_eip" {
  instance = aws_instance.keycloak.id
  vpc      = true
}
