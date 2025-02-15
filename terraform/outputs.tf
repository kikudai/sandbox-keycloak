output "alb_dns_name" {
  description = "ALB の DNS 名。お名前ドットコム側で、カスタムドメインの CNAME（または ALIAS）として設定してください。"
  value       = module.alb.alb_dns_name
}

output "keycloak_url_https" {
  description = "HTTPS 経由でアクセスする場合の URL（カスタムドメイン利用時）"
  value       = "https://${var.domain_name}"
}
