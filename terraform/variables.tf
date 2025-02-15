variable "key_name" {
  description = "EC2 インスタンスに SSH 接続するためのキーペア名"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "SSH アクセスを許可する CIDR ブロック（例: xxx.xxx.xxx.xxx/32）"
  type        = string
}

variable "certificate_arn" {
  description = "ALB 用 HTTPS で使用する ACM 証明書の ARN"
  type        = string
}
