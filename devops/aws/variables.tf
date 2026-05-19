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

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository EC2 instances are allowed to pull from (created in ops#17)"
  type        = string
}

variable "logs_bucket_name" {
  # TODO: S3 logs bucket does not exist yet — create the bucket and pass its name here (see ops#19)
  description = "Name of the S3 bucket where EC2 instances write logs"
  type        = string
}
