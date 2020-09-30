data "vault_generic_secret" "postgres_secrets" {
  path  = "secret/postgres"
}

module "postgres" {
  source = "./.."

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # postgres
  service_name                    = "postgres"
  container_image                 = "postgres:12-alpine"
  container_port                  = 5432
  admin_user                      = data.vault_generic_secret.postgres_secrets.data.username
  admin_password                  = data.vault_generic_secret.postgres_secrets.data.password
  database                        = "metastore"
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data"]
}
