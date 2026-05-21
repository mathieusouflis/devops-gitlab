output "dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.prod.dns_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.prod.arn
}

output "arn_suffix" {
  description = "ARN suffix of the ALB used by CloudWatch metric dimensions"
  value       = aws_lb.prod.arn_suffix
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group used by CloudWatch metric dimensions"
  value       = aws_lb_target_group.prod.arn_suffix
}

output "security_group_id" {
  description = "Security Group ID of the ALB"
  value       = aws_security_group.alb.id
}
