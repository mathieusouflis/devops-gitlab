  resource "aws_ssm_parameter" "postgres_user" {
  name  = "${var.environment}/POSTGRES_USER"
  type  = "SecureString"
  value = var.postgres_user # placeholder — set the real value manually after first apply

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "postgres_password" {
  name  = "${var.environment}/POSTGRES_PASSWORD"
  type  = "SecureString"
  value = var.postgres_password # placeholder — set the real value manually after first apply

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "postgres_db" {
  name  = "${var.environment}/POSTGRES_DB"
  type  = "String"
  value = var.postgres_db
}

resource "aws_ssm_parameter" "backend_port" {
  name  = "${var.environment}/BACKEND_PORT"
  type  = "String"
  value = var.backend_port
}

resource "aws_ssm_parameter" "cors_origin" {
  name  = "${var.environment}/CORS_ORIGIN"
  type  = "String"
  value = "http://${var.alb_dns_name}"
}

resource "aws_ssm_parameter" "vite_frontend_port" {
  name  = "${var.environment}/VITE_FRONTEND_PORT"
  type  = "String"
  value = var.vite_frontend_port
}

resource "aws_ssm_parameter" "http_port" {
  name  = "${var.environment}/HTTP_PORT"
  type  = "String"
  value = var.http_port
}

resource "aws_ssm_parameter" "vite_frontend_api_url" {
  name  = "${var.environment}/VITE_FRONTEND_API_URL"
  type  = "String"
  value = "http://${var.alb_dns_name}/api"
}
