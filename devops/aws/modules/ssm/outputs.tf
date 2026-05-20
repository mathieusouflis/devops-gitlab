output "parameter_prefix" {
  description = "SSM parameter path prefix used by EC2 instances"
  value       = "/group1/${var.environment}"
}
