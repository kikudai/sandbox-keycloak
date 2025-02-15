provider "aws" {
  region = "ap-northeast-1"  # 必要に応じて変更
}

#############################
# VPC, サブネット, IGW, ルートテーブル
#############################

resource "aws_vpc" "keycloak_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Keycloak-VPC"
  }
}

resource "aws_subnet" "keycloak_public_subnet" {
  vpc_id                  = aws_vpc.keycloak_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-northeast-1a"  # 必要に応じて変更
  map_public_ip_on_launch = true

  tags = {
    Name = "Keycloak-Public-Subnet"
  }
}

resource "aws_internet_gateway" "keycloak_igw" {
  vpc_id = aws_vpc.keycloak_vpc.id

  tags = {
    Name = "Keycloak-IGW"
  }
}

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

resource "aws_route_table_association" "keycloak_public_rt_assoc" {
  subnet_id      = aws_subnet.keycloak_public_subnet.id
  route_table_id = aws_route_table.keycloak_public_rt.id
}

#############################
# EC2 インスタンス (Amazon Linux 2023)
#############################

# Amazon Linux 2023 の最新 AMI を取得
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]  # Amazon 公式 AMI のオーナーID
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

# EC2 用セキュリティグループ（SSH は allowed_ssh_cidr で許可）
resource "aws_security_group" "keycloak_ec2_sg" {
  name        = "keycloak-ec2-sg"
  description = "EC2 用セキュリティグループ（Keycloak コンテナ実行）"
  vpc_id      = aws_vpc.keycloak_vpc.id

  ingress {
    from_port   = 80    # Keycloak コンテナはホストの80番で待ち受け
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]  # 同一 VPC 内からのアクセス（ALB から）
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

# EC2 インスタンス作成（User Data 内で Docker インストール＆ Keycloak 起動）
resource "aws_instance" "keycloak" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"  # Free Tier 対象
  subnet_id                   = aws_subnet.keycloak_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.keycloak_ec2_sg.id]
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

#############################
# ALB 関連設定
#############################

# ALB 用セキュリティグループ（HTTP / HTTPS 共に許可）
resource "aws_security_group" "keycloak_alb_sg" {
  name        = "keycloak-alb-sg"
  description = "ALB 用セキュリティグループ（HTTP/HTTPS）"
  vpc_id      = aws_vpc.keycloak_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB の作成
resource "aws_lb" "keycloak_alb" {
  name               = "keycloak-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.keycloak_alb_sg.id]
  subnets            = [aws_subnet.keycloak_public_subnet.id]

  tags = {
    Name = "Keycloak-ALB"
  }
}

# ALB ターゲットグループ（EC2 インスタンスへ HTTP で転送）
resource "aws_lb_target_group" "keycloak_tg" {
  name     = "keycloak-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.keycloak_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

# ALB ターゲットグループへの EC2 アタッチメント
resource "aws_lb_target_group_attachment" "keycloak_attachment" {
  target_group_arn = aws_lb_target_group.keycloak_tg.arn
  target_id        = aws_instance.keycloak.id
  port             = 80
}

# ALB の HTTPS リスナー（ポート 443）設定（ACM 証明書を利用）
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.keycloak_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.keycloak_tg.arn
  }
}

# ALB の HTTP リスナー（ポート 80）設定 → HTTPS へリダイレクト
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.keycloak_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}
