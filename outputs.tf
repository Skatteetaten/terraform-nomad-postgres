output "service_name" {
  description = "Postgres service name"
  value       = data.template_file.template-nomad-job-postgres.vars.service_name
}

output "username" {
  description = "Postgres username"
  value       = data.template_file.template-nomad-job-postgres.vars.username
}

output "password" {
  description = "Postgres password"
  value       = data.template_file.template-nomad-job-postgres.vars.password
}

output "database_name" {
  description = "Postgres database name"
  value       = data.template_file.template-nomad-job-postgres.vars.database
}

output "port" {
  description = "Postgres port"
  value       = data.template_file.template-nomad-job-postgres.vars.port
}

