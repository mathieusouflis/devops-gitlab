variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository EC2 instances are allowed to pull from"
  type        = string
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket EC2 instances are allowed to write logs to"
  type        = string
}
