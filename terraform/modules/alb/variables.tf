variable "vpc_id" {
  description = "VPC の ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "ALB を配置するパブリックサブネットの ID のリスト"
  type        = list(string)
}

variable "domain_name" {
  description = "カスタムドメイン名（例: keycloak.example.com）"
  type        = string
}

variable "instance_id" {
  description = "Compute モジュールで作成された EC2 インスタンスの ID"
  type        = string
}
