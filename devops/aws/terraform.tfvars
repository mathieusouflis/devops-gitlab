aws_region = "eu-north-1"

vpc_cidr = "10.0.0.0/16"
az1      = "eu-north-1a"
az2      = "eu-north-1b"

ecr_repository_arn = "arn:aws:ecr:eu-north-1:622333992348:repository/group1/devops-project"

logs_bucket_name = "devops-project-group1-logs"

app_postgres_db           = "devops_project"
app_backend_port          = "3000"
app_vite_frontend_port    = "5173"
app_http_port             = "80"
app_cors_origin           = "*"
app_vite_frontend_api_url = "http://localhost/api"
