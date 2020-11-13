locals {
  datacenters = join(",", var.nomad_datacenters)
  postgres_env_vars = join("\n",
    concat([
      "POSTGRES_DB=${var.database}"
    ], var.container_environment_variables)
  )
}

data "template_file" "template_nomad_job_postgres" {
  template = file("${path.module}/conf/nomad/postgres.hcl")
  vars = {
    service_name         = var.service_name
    cpu_proxy            = var.resource_proxy.cpu
    memory_proxy         = var.resource_proxy.memory
    datacenters          = local.datacenters
    namespace            = var.nomad_namespace
    image                = var.container_image
    port                 = var.container_port
    username             = var.admin_user
    password             = var.admin_password
    use_vault_provider   = var.vault_secret.use_vault_provider
    vault_kv_policy_name = var.vault_secret.vault_kv_policy_name
    vault_kv_path        = var.vault_secret.vault_kv_path
    vault_kv_username    = var.vault_secret.vault_kv_username_name
    vault_kv_password    = var.vault_secret.vault_kv_password_name
    database             = var.database
    nomad_host_volume    = var.nomad_host_volume
    volume_destination   = var.volume_destination
    use_host_volume      = var.use_host_volume
    use_canary           = var.use_canary
    memory               = var.memory
    cpu                  = var.cpu
    envs                 = local.postgres_env_vars
  }
}

resource "nomad_job" "nomad_job_postgres" {
  jobspec = data.template_file.template_nomad_job_postgres.rendered
  detach  = false
}
