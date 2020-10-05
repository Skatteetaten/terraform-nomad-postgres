data "vault_generic_secret" "postgres_secrets" {
  path  = "secret/postgres"
}

module "postgres" {
  source = "./.."

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"
  nomad_host_volume = "persistence"

  # postgres
  service_name                    = "postgres"
  container_image                 = "postgres:12-alpine"
  container_port                  = 5432
  admin_user                      = data.vault_generic_secret.postgres_secrets.data.username
  admin_password                  = data.vault_generic_secret.postgres_secrets.data.password
  database                        = "metastore"
  volume_destination              = "/var/lib/postgresql/data"
  use_host_volume                 = true
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data/"]
}
