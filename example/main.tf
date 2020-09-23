data "vault_generic_secret" "postgres_secrets" {
  path  = "secret/postgres"
}

module "postgres" {
  source = "./.."

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # postgres
  postgres_service_name                    = "postgres"
  postgres_container_image                 = "postgres:12-alpine"
  postgres_container_port                  = 5432
  postgres_admin_user                      = data.vault_generic_secret.postgres_secrets.data.username
  postgres_admin_password                  = data.vault_generic_secret.postgres_secrets.data.password
  postgres_database                        = "metastore"
  postgres_container_environment_variables = ["PGDATA=/var/lib/postgresql/data"]
}

output "postgres_service_name"{
  description = "Postgres service name"
  value       = module.postgres.service_name
}

output "postgres_db_name"{
  description = "Postgres database name"
  value       = module.postgres.database_name
}

output "postgres_username" {
  description = "Postgres username"
  value       = data.vault_generic_secret.postgres_secrets.data.username
  sensitive   = true
}

output "postgres_password" {
  description = "Postgres password"
  value       = data.vault_generic_secret.postgres_secrets.data.password
  sensitive   = true
}