output "alb_dns_name" {
  description = "ALB の DNS 名。お名前ドットコム側でカスタムドメインの CNAME (または ALIAS) として設定してください。"
  value       = aws_lb.alb.dns_name
}
