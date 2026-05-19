variable "ecr_repository_arn" {
  description = "ARN of the ECR repository EC2 instances are allowed to pull from"
  type        = string
}

variable "logs_bucket_name" {
  # TODO: S3 logs bucket does not exist yet — create it and pass the name here (see ops#19)
  description = "Name of the S3 bucket where EC2 instances write logs (bucket not yet created)"
  type        = string
}
