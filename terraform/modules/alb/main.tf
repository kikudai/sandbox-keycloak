# 1. ACM 証明書の作成（DNS 検証）
#    → お名前ドットコムで手動で CNAME レコードを作成し、コンソール上で「発行済み」になればOK
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 2. ALB 用セキュリティグループ
resource "aws_security_group" "alb_sg" {
  name        = "keycloak-alb-sg"
  description = "ALB security group (HTTP/HTTPS)"
  vpc_id      = var.vpc_id

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

# 3. ALB の作成
resource "aws_lb" "alb" {
  name               = "keycloak-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.subnet_id]
  internal           = false

  tags = {
    Name = "Keycloak-ALB"
  }
}

# 4. ターゲットグループ（EC2 へ HTTP で転送）
resource "aws_lb_target_group" "tg" {
  name     = "keycloak-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

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

# 5. ターゲットグループへの EC2 アタッチメント
resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.instance_id
  port             = 80
}

# 6. HTTPS リスナー（port: 443）
#    certificate_arn に aws_acm_certificate.cert.arn を直接指定
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# 7. HTTP リスナー（port: 80） → HTTPS リダイレクト
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
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
