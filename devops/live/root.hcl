locals {
  common_inputs = {
    aws_region = "eu-north-1"
    vpc_cidr   = "10.0.0.0/16"
    az1        = "eu-north-1a"
    az2        = "eu-north-1b"

    logs_bucket_name       = "devops-project-group1-logs"
    app_postgres_user      = get_env("TF_VAR_app_postgres_user", "change-me")
    app_postgres_password  = get_env("TF_VAR_app_postgres_password", "change-me")
    app_postgres_db        = "devops_project"
    app_backend_port       = "3000"
    app_vite_frontend_port = "5173"
    app_http_port          = "80"
  }
}

inputs = local.common_inputs
