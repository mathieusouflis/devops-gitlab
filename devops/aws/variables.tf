variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
}

variable "az1" {
  description = "AZ1"
  type        = string
}

variable "az2" {
  description = "AZ2"
  type        = string
}
