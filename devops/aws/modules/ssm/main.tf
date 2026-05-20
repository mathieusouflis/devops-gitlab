locals {
  ssm_prefix = "/group1/${var.environment}"
}

resource "aws_ssm_parameter" "postgres_user" {
  name  = "${local.ssm_prefix}/POSTGRES_USER"
  type  = "SecureString"
  value = var.postgres_user # placeholder — set the real value manually after first apply

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "postgres_password" {
  name  = "${local.ssm_prefix}/POSTGRES_PASSWORD"
  type  = "SecureString"
  value = var.postgres_password # placeholder — set the real value manually after first apply

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "postgres_db" {
  name  = "${local.ssm_prefix}/POSTGRES_DB"
  type  = "String"
  value = var.postgres_db
}

resource "aws_ssm_parameter" "backend_port" {
  name  = "${local.ssm_prefix}/BACKEND_PORT"
  type  = "String"
  value = var.backend_port
}

resource "aws_ssm_parameter" "cors_origin" {
  name  = "${local.ssm_prefix}/CORS_ORIGIN"
  type  = "String"
  value = "http://${var.alb_dns_name}"
}

resource "aws_ssm_parameter" "vite_frontend_port" {
  name  = "${local.ssm_prefix}/VITE_FRONTEND_PORT"
  type  = "String"
  value = var.vite_frontend_port
}

resource "aws_ssm_parameter" "http_port" {
  name  = "${local.ssm_prefix}/HTTP_PORT"
  type  = "String"
  value = var.http_port
}

resource "aws_ssm_parameter" "vite_frontend_api_url" {
  name  = "${local.ssm_prefix}/VITE_FRONTEND_API_URL"
  type  = "String"
  value = "http://${var.alb_dns_name}/api"
}
