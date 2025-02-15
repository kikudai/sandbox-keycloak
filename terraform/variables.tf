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
  description = "キーペアの名前 (例: sandbox-keycloak)"
  type        = string
}

variable "domain_name" {
  description = "カスタムドメイン名（例: keycloak.example.com）"
  type        = string
}

variable "manual_validation_fqdns" {
  description = "手動で作成した ACM DNS 検証レコード FQDN のリスト"
  type        = list(string)
  default     = []
}
