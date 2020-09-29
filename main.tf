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
