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

variable "alb_dns_name" {
  description = "ALB DNS name used to compute CORS origin and API URL"
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

