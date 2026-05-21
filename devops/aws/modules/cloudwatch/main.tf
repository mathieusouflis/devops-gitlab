locals {
  log_group_prefix = "/group1/${var.environment}"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "${local.log_group_prefix}/app"
  retention_in_days = var.retention_in_days

  tags = {
    Name = "${var.environment}-app-logs"
    Env  = var.environment
  }
}

resource "aws_cloudwatch_log_group" "system" {
  name              = "${local.log_group_prefix}/system"
  retention_in_days = var.retention_in_days

  tags = {
    Name = "${var.environment}-system-logs"
    Env  = var.environment
  }
}

resource "aws_sns_topic" "alarms" {
  name = "${var.environment}-monitoring-alerts"

  tags = {
    Name = "${var.environment}-monitoring-alerts"
    Env  = var.environment
  }
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.alarm_notification_emails)

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.environment}-cpu-utilization-high"
  alarm_description   = "CPU utilization is above 80 percent for 5 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  tags = {
    Name = "${var.environment}-cpu-utilization-high"
    Env  = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.environment}-memory-utilization-high"
  alarm_description   = "Memory utilization is above 85 percent for 5 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  tags = {
    Name = "${var.environment}-memory-utilization-high"
    Env  = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_high" {
  alarm_name          = "${var.environment}-alb-target-5xx-high"
  alarm_description   = "ALB target 5xx errors are above 5 per minute"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  tags = {
    Name = "${var.environment}-alb-target-5xx-high"
    Env  = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time_high" {
  alarm_name          = "${var.environment}-alb-target-response-time-high"
  alarm_description   = "ALB target response time is above 2 seconds for 5 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  tags = {
    Name = "${var.environment}-alb-target-response-time-high"
    Env  = var.environment
  }
}
