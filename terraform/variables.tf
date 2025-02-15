variable "key_name" {
  description = "EC2インスタンスにSSH接続するためのキーペア名"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "SSHアクセスを許可するCIDRブロック（例: xxx.xxx.xxx.xxx/32）"
  type        = string
}
