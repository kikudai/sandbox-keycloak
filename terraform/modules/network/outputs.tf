output "vpc_id" {
  description = "作成された VPC の ID"
  value       = aws_vpc.this.id
}

output "public_subnet_a_id" {
  description = "パブリックサブネット A の ID"
  value       = aws_subnet.public_a.id
}

output "public_subnet_c_id" {
  description = "パブリックサブネット C の ID"
  value       = aws_subnet.public_c.id
}
