output "elastic_ip" {
  description = "EC2インスタンスに割り当てられたElastic IP。お名前ドットコムのDNS設定でAレコードに設定してください。"
  value       = aws_eip.keycloak_eip.public_ip
}

output "keycloak_url" {
  description = "KeycloakのURL（Elastic IP経由）。DNS設定後は、カスタムドメインでアクセスできます。"
  value       = "http://${aws_eip.keycloak_eip.public_ip}"
}
