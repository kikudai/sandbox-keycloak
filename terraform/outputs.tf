output "alb_dns_name" {
  description = "ALB の DNS 名。カスタムドメインの CNAME (または ALIAS) として設定してください。"
  value       = aws_lb.keycloak_alb.dns_name
}

output "keycloak_url_https" {
  description = "HTTPS 経由でアクセスする場合の URL（カスタムドメイン利用時）"
  value       = "https://${var.certificate_arn != "" ? var.certificate_arn : aws_lb.keycloak_alb.dns_name}"
}
