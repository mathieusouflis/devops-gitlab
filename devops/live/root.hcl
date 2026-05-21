locals {
  common_inputs = {
    aws_region = "eu-south-2"
    vpc_cidr   = "10.0.0.0/16"
    az1        = "eu-south-2a"
    az2        = "eu-south-2b"

    logs_bucket_name       = "devops-project-group1-logs"
    alb_access_logs_prefix = "alb"
    logs_bucket_expiration_days = 30
    cloudwatch_log_retention_days = 14
    alarm_notification_emails = []
    app_postgres_user      = get_env("TF_VAR_app_postgres_user", "change-me")
    app_postgres_password  = get_env("TF_VAR_app_postgres_password", "change-me")
    app_postgres_db        = "devops_project"
    app_backend_port       = "3000"
    app_vite_frontend_port = "5173"
    app_http_port          = "80"
  }
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "local" {
    path = "${replace(get_terragrunt_dir(), "\\", "/")}/terraform.tfstate"
  }
}
EOF
}

inputs = local.common_inputs
