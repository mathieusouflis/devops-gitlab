variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["prod", "staging"], var.environment)
    error_message = "environment must be prod or staging."
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
  # TODO: S3 logs bucket does not exist yet — create the bucket and pass its name here (see ops#19)
  description = "Name of the S3 bucket where EC2 instances write logs"
  type        = string
}

# App config — written to SSM Parameter Store under /prod/*

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