output "service_name" {
  description = "Postgres service name"
  value       = data.template_file.template_nomad_job_postgres.vars.service_name
}

output "username" {
  description = "Postgres username"
  value       = data.template_file.template_nomad_job_postgres.vars.username
  sensitive = true
}

output "password" {
  description = "Postgres password"
  value       = data.template_file.template_nomad_job_postgres.vars.password
  sensitive = true
}

output "database_name" {
  description = "Postgres database name"
  value       = data.template_file.template_nomad_job_postgres.vars.database
}

output "port" {
  description = "Postgres port"
  value       = data.template_file.template_nomad_job_postgres.vars.port
}

