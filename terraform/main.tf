provider "aws" {
  region = "ap-northeast-1"  # 必要に応じて変更
}

###########################
# 新規VPC, サブネット作成 #
###########################

# VPCの作成（CIDRブロックを 10.1.0.0/16 に変更）
resource "aws_vpc" "keycloak_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Keycloak-VPC"
  }
}

# パブリックサブネットの作成（CIDRブロックを 10.1.1.0/24 に変更）
resource "aws_subnet" "keycloak_public_subnet" {
  vpc_id                  = aws_vpc.keycloak_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-northeast-1a"  # 必要に応じて変更
  map_public_ip_on_launch = true

  tags = {
    Name = "Keycloak-Public-Subnet"
  }
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "keycloak_igw" {
  vpc_id = aws_vpc.keycloak_vpc.id

  tags = {
    Name = "Keycloak-IGW"
  }
}

# パブリックサブネット用のルートテーブルの作成
resource "aws_route_table" "keycloak_public_rt" {
  vpc_id = aws_vpc.keycloak_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.keycloak_igw.id
  }

  tags = {
    Name = "Keycloak-Public-RT"
  }
}

# ルートテーブルとサブネットの関連付け
resource "aws_route_table_association" "keycloak_public_rt_assoc" {
  subnet_id      = aws_subnet.keycloak_public_subnet.id
  route_table_id = aws_route_table.keycloak_public_rt.id
}

#########################################
# EC2インスタンス (Amazon Linux 2023)  #
#########################################

# Amazon Linux 2023 の最新AMIを取得
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]  # Amazon公式AMIのオーナーID
  filter {
    name   = "name"
    values = ["al2023-ami-kernel-default-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# セキュリティグループの作成
resource "aws_security_group" "keycloak_sg" {
  name        = "keycloak-sg"
  description = "Keycloak用のセキュリティグループ"
  vpc_id      = aws_vpc.keycloak_vpc.id

  # HTTP (80番ポート) を全世界から許可
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (22番ポート) ※管理用。YOUR_IP/32 をご自身のIPに変更してください
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
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"  # Free Tier対象
  subnet_id                   = aws_subnet.keycloak_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.keycloak_sg.id]
  key_name                    = var.key_name  # 事前作成済みのSSHキーペア名
  associate_public_ip_address = true

  # User Data: DockerのインストールとKeycloakコンテナの起動
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
    usermod -a -G docker ec2-user
    # ホストの80番ポート → コンテナの8080番ポートにマッピング
    docker run -d --name keycloak -p 80:8080 quay.io/keycloak/keycloak:17.0.1 start-dev
  EOF

  tags = {
    Name = "Keycloak-EC2"
  }
}

# Elastic IP の割り当て（固定パブリックIP）
resource "aws_eip" "keycloak_eip" {
  instance = aws_instance.keycloak.id
  vpc      = true
}
