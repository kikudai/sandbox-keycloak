output "instance_id" {
  description = "EC2 instance ID for Keycloak"
  value       = aws_instance.keycloak.id
}

output "instance_public_ip" {
  description = "EC2 instance public IP for Keycloak"
  value       = aws_instance.keycloak.public_ip
}
