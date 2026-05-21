variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "az1" {
  type        = string
  description = "Availability Zone 1"
}

variable "az2" {
  type        = string
  description = "Availability Zone 2"
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
}
