output "app_log_group_name" {
  description = "Name of the CloudWatch log group receiving container logs"
  value       = aws_cloudwatch_log_group.app.name
}

output "system_log_group_name" {
  description = "Name of the CloudWatch log group receiving instance system logs"
  value       = aws_cloudwatch_log_group.system.name
}

output "alarm_topic_arn" {
  description = "SNS topic ARN used by CloudWatch alarms"
  value       = aws_sns_topic.alarms.arn
}
