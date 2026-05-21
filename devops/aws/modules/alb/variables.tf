variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "access_logs_bucket_name" {
  description = "S3 bucket name receiving ALB access logs"
  type        = string
}

variable "access_logs_prefix" {
  description = "Prefix used by ALB when writing access logs"
  type        = string
  default     = "alb"
}
