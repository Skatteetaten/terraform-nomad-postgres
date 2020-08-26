module "postgres" {
  source = "./.."

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # postgres
  postgres_service_name                    = "postgres"
  postgres_container_image                 = "postgres:12-alpine"
  postgres_container_port                  = 5432
  postgres_admin_user                      = "hive"
  postgres_admin_password                  = "hive"
  postgres_database                        = "metastore"
  postgres_container_environment_variables = ["PGDATA=/var/lib/postgresql/data"]
}
