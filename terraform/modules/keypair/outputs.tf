output "key_name" {
  description = "作成されたキーペア名"
  value       = aws_key_pair.this.key_name
}

output "private_key" {
  description = "生成された秘密鍵 (機密扱い)"
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}
