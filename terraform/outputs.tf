// Root outputs.tf

// Network モジュールの出力
output "vpc_id" {
  description = "VPC ID from network module"
  value       = module.network.vpc_id
}

output "public_subnet_a_id" {
  description = "Public Subnet A ID"
  value       = module.network.public_subnet_a_id
}

output "public_subnet_c_id" {
  description = "Public Subnet C ID"
  value       = module.network.public_subnet_c_id
}

// Keypair モジュールの出力
output "keypair_key_name" {
  description = "AWS Key Pair name created by keypair module"
  value       = module.keypair.key_name
}

output "keypair_private_key" {
  description = "Private key from keypair module (sensitive)"
  value       = module.keypair.private_key
  sensitive   = true
}

// Compute モジュールの出力
output "instance_id" {
  description = "EC2 instance ID for Keycloak"
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "EC2 instance public IP for Keycloak"
  value       = module.compute.instance_public_ip
}

// ALB モジュールの出力
output "alb_dns_name" {
  description = "ALB DNS name. Use this as the CNAME (or ALIAS) record in your DNS provider."
  value       = module.alb.alb_dns_name
}

// アクセス用 URL（カスタムドメイン利用時）
output "keycloak_url_https" {
  description = "HTTPS URL to access Keycloak"
  value       = "https://${var.domain_name}"
}
