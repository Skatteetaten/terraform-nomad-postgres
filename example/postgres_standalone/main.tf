module "postgres" {
  source = "../.."

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"
  nomad_host_volume = "persistence"

  # postgres
  service_name                    = "postgres"
  container_image                 = "postgres:12-alpine"
  container_port                  = 5432
  vault_secret                    = {
                                      use_vault_provider     = true,
                                      vault_kv_policy_name   = "kv-secret",
                                      vault_kv_path          = "secret/data/postgres",
                                      vault_kv_username_name = "username",
                                      vault_kv_password_name = "password"
                                    }
  database                        = "metastore"
  volume_destination              = "/var/lib/postgresql/data"
  use_host_volume                 = true
  use_canary                      = false
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data/"]
}
