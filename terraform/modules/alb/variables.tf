variable "vpc_id" {
  description = "Network モジュールから渡される VPC の ID"
  type        = string
}

variable "subnet_id" {
  description = "Network モジュールから渡されるサブネットの ID（ALB 用）"
  type        = string
}

variable "domain_name" {
  description = "公開するカスタムドメイン名（例: keycloak.example.com）"
  type        = string
}

variable "manual_validation_fqdns" {
  description = "手動で作成した ACM DNS 検証レコードの FQDN のリスト"
  type        = list(string)
  default     = []
}

variable "instance_id" {
  description = "Compute モジュールから渡される EC2 インスタンスの ID"
  type        = string
}
