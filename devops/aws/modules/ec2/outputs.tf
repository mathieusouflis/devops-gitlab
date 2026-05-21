output "sg_ec2_prod_id" {
  description = "Security Group ID for EC2 instances"
  value       = aws_security_group.ec2_prod.id
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.prod.id
}

output "launch_template_latest_version" {
  description = "Latest version number of the Launch Template"
  value       = aws_launch_template.prod.latest_version
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.prod.name
}
