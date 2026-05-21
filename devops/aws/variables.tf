variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["production", "staging"], var.environment)
    error_message = "environment must be production or staging."
  }
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

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository EC2 instances are allowed to pull from (created in ops#17)"
  type        = string
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket receiving ALB access logs"
  type        = string
}

variable "alb_access_logs_prefix" {
  description = "Prefix used by ALB when writing access logs to S3"
  type        = string
  default     = "alb"
}

variable "logs_bucket_expiration_days" {
  description = "Number of days to keep ALB access logs in S3"
  type        = number
  default     = 30
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch log groups"
  type        = number
  default     = 14
}

variable "alarm_notification_emails" {
  description = "Email addresses subscribed to CloudWatch alarm notifications"
  type        = list(string)
  default     = []
}

# App config — written to SSM Parameter Store under /<environment>/*

variable "app_postgres_user" {
  description = "PostgreSQL username"
  type        = string
  sensitive   = true
}

variable "app_postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "app_postgres_db" {
  description = "PostgreSQL database name"
  type        = string
}

variable "app_backend_port" {
  description = "Port the backend container listens on"
  type        = string
}

variable "app_vite_frontend_port" {
  description = "Port the frontend container listens on"
  type        = string
}

variable "app_http_port" {
  description = "Host port nginx binds to"
  type        = string
  default     = "80"
}