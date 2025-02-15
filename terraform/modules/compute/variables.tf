variable "vpc_id" {
  description = "Network モジュールから渡される VPC の ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 インスタンスタイプ"
  type        = string
  default     = "t4g.micro"
}

variable "subnet_id" {
  description = "EC2 インスタンスを配置するサブネットの ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC の CIDR ブロック"
  type        = string
  default     = "10.1.0.0/16"
}

variable "allowed_ssh_cidr" {
  description = "SSH アクセスを許可する CIDR ブロック（例: 203.0.113.4/32）"
  type        = string
}

variable "key_name" {
  description = "EC2 用 SSH キーペア名"
  type        = string
}

# Keycloak の環境変数（Terraform.tfvars から設定）
variable "keycloak_admin" {
  description = "Keycloak admin username"
  type        = string
}

variable "keycloak_admin_password" {
  description = "Keycloak admin password"
  type        = string
}
