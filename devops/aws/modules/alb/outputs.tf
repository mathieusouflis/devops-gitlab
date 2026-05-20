output "dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.prod.dns_name
}

output "target_group_arn" {
  description = "ARN of the PROD target group"
  value       = aws_lb_target_group.prod.arn
}

output "security_group_id" {
  description = "Security Group ID of the ALB"
  value       = aws_security_group.alb.id
}
