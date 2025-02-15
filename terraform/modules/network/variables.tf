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

variable "public_subnet_a_cidr" {
  description = "パブリックサブネット A の CIDR ブロック"
  type        = string
  default     = "10.1.1.0/24"
}

variable "public_subnet_c_cidr" {
  description = "パブリックサブネット C の CIDR ブロック"
  type        = string
  default     = "10.1.2.0/24"
}

variable "availability_zone_a" {
  description = "パブリックサブネット A の Availability Zone"
  type        = string
  default     = "ap-northeast-1a"
}

variable "availability_zone_c" {
  description = "パブリックサブネット C の Availability Zone"
  type        = string
  default     = "ap-northeast-1c"
}
