variable "vpc_id" {
  description = "Network モジュールから渡される VPC の ID"
  type        = string
}

variable "subnet_id" {
  description = "Network モジュールから渡されるサブネットの ID"
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
  description = "EC2 インスタンス用の SSH キーペア名"
  type        = string
}
