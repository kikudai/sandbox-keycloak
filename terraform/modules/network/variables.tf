variable "vpc_cidr" {
  description = "VPC の CIDR ブロック"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_name" {
  description = "VPC の名前"
  type        = string
  default     = "keycloak-vpc"
}

variable "subnet_cidr" {
  description = "パブリックサブネットの CIDR ブロック"
  type        = string
  default     = "10.1.1.0/24"
}

variable "subnet_name" {
  description = "パブリックサブネットの名前"
  type        = string
  default     = "keycloak-public-subnet"
}

variable "availability_zone" {
  description = "利用する Availability Zone"
  type        = string
  default     = "ap-northeast-1a"
}
