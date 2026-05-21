variable "bucket_name" {
  description = "Name of the S3 bucket receiving ALB access logs"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "access_logs_prefix" {
  description = "Prefix used by ALB when writing access logs"
  type        = string
  default     = "alb"
}

variable "expiration_days" {
  description = "Number of days to keep access logs in S3"
  type        = number
  default     = 30
}
