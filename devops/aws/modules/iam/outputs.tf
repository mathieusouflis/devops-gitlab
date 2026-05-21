output "ecr_read_role_arn" {
  description = "ARN of EC2-ECR-ReadRole"
  value       = aws_iam_role.ecr_read.arn
}

output "ecr_read_role_name" {
  description = "Name of EC2-ECR-ReadRole"
  value       = aws_iam_role.ecr_read.name
}

output "ecr_read_instance_profile_arn" {
  description = "ARN of the instance profile for EC2-ECR-ReadRole"
  value       = aws_iam_instance_profile.ecr_read.arn
}

output "ecr_read_instance_profile_name" {
  description = "Name of the instance profile for EC2-ECR-ReadRole (use this in ASG launch templates)"
  value       = aws_iam_instance_profile.ecr_read.name
}
