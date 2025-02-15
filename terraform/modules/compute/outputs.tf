output "instance_id" {
  value = aws_instance.keycloak.id
}

output "instance_public_ip" {
  value = aws_instance.keycloak.public_ip
}
