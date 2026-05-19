variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
}

variable "backend_port" {
  description = "Port the backend container listens on"
  type        = string
}

# TODO(ALB): replace with module.alb.dns_name output once the ALB module exists
#            and remove this variable entirely
variable "cors_origin" {
  description = "Allowed CORS origin (use * temporarily, replace with http://alb-dns once ALB exists)"
  type        = string
}

variable "vite_frontend_port" {
  description = "Port the frontend container listens on"
  type        = string
}

variable "http_port" {
  description = "Host port nginx binds to"
  type        = string
  default     = "80"
}

# TODO(ALB): replace with "http://${module.alb.dns_name}/api" once the ALB module exists
#            and remove this variable entirely
variable "vite_frontend_api_url" {
  description = "API base URL consumed by the frontend (set to match cors_origin)"
  type        = string
}
