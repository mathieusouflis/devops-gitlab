variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ASG"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR block, used to scope SG inbound rule for ALB traffic"
  type        = string
}

variable "ecr_registry" {
  description = "ECR registry hostname (account.dkr.ecr.region.amazonaws.com)"
  type        = string
}

variable "ecr_repository_uri" {
  description = "Full ECR repository URI used as image prefix in docker-compose.ecr.yaml"
  type        = string
}

variable "ecr_read_instance_profile_name" {
  description = "IAM instance profile name to attach to EC2 instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to attach the ASG to"
  type        = string
}
