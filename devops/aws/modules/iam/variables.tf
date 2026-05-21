variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository EC2 instances are allowed to pull from"
  type        = string
}
