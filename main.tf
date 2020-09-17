locals {

  datacenters = join(",", var.nomad_datacenters)
  postgres_env_vars = join("\n",
    concat([
      "POSTGRES_DB=${var.postgres_database}",
      "POSTGRES_USER=${var.postgres_admin_user}",
      "POSTGRES_PASSWORD=${var.postgres_admin_password}"
    ], var.postgres_container_environment_variables)
  )

}

data "template_file" "template-nomad-job-postgres" {

  template = file("${path.module}/conf/nomad/postgres.hcl")

  vars = {
    service_name = var.postgres_service_name
    datacenters  = local.datacenters
    namespace    = var.nomad_namespace
    image        = var.postgres_container_image
    port         = var.postgres_container_port
    username     = var.postgres_admin_user
    password     = var.postgres_admin_password
    database     = var.postgres_database

    envs = local.postgres_env_vars
  }

}

resource "nomad_job" "nomad-job-postgres" {
  jobspec = data.template_file.template-nomad-job-postgres.rendered
  detach  = false
}


data "template_file" "template-nomad-job-unsafe_connection" {
  template = file("${path.module}/conf/nomad/unsafe_connection.hcl")
}

resource "nomad_job" "nomad-job-unsafe_connection" {
  jobspec = data.template_file.template-nomad-job-unsafe_connection.rendered
  detach = false
}

resource "vault_mount" "db" {
  path = "postgres"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.db.path
  name          = "postgres"
  allowed_roles = ["dev", "prod"]

  postgresql {
    connection_url = "postgres://hive:hive@127.0.0.1:4567/postgres?sslmode=disable"
  }
}

resource "vault_database_secret_backend_role" "role" {
  backend             = vault_mount.db.path
  name                = "my-role"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
}
