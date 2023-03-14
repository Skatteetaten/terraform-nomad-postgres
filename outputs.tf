output "service_name" {
  description = "Postgres service name"
  value       = var.service_name
}

output "username" {
  description = "Postgres username (if not using Vault)"
  value       = var.admin_user
  sensitive   = true
}

output "password" {
  description = "Postgres password (if not using Vault)"
  value       = var.admin_password
  sensitive   = true
}

output "database_name" {
  description = "Postgres database name"
  value       = var.database
}

output "port" {
  description = "Postgres port"
  value       = var.container_port
}
