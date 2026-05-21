variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name used for EC2 and CWAgent metric dimensions"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix used for Application Load Balancer alarm dimensions"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix used for Application Load Balancer alarm dimensions"
  type        = string
}

variable "alarm_notification_emails" {
  description = "Email addresses subscribed to CloudWatch alarm notifications"
  type        = list(string)
  default     = []
}
