output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "keycloak_url_https" {
  value = "https://${var.domain_name}"
}
