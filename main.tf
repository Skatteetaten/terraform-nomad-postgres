locals {
  datacenters = join(",", var.nomad_datacenters)
  postgres_env_vars = join("\n",
    concat([
      "POSTGRES_DB=${var.database}",
      "POSTGRES_USER=${var.admin_user}",
      "POSTGRES_PASSWORD=${var.admin_password}"
    ], var.container_environment_variables)
  )
}

data "template_file" "template-nomad-job-postgres" {
  template = file("${path.module}/conf/nomad/postgres.hcl")
  vars = {
    service_name = var.service_name
    datacenters  = local.datacenters
    namespace    = var.nomad_namespace
    image        = var.container_image
    port         = var.container_port
    username     = var.admin_user
    password     = var.admin_password
    database     = var.database
    envs = local.postgres_env_vars
  }
}

resource "nomad_job" "nomad-job-postgres" {
  jobspec = data.template_file.template-nomad-job-postgres.rendered
  detach  = false
}
