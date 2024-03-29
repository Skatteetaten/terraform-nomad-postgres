# Nomad
variable "nomad_datacenters" {
  type        = list(string)
  description = "Nomad data centers"
  default     = ["dc1"]
}
variable "nomad_namespace" {
  type        = string
  description = "[Enterprise] Nomad namespace"
  default     = "default"
}
variable "nomad_host_volume" {
  type        = string
  description = "Nomad Host Volume"
  default     = "persistence"
}

# Consul
variable "consul_tags" {
    type = list(string)
    default = [""]
    description = "List of one or more tags to announce in Consul, for service discovery purposes"
}

# Postgres
variable "service_name" {
  type        = string
  description = "Postgres service name"
  default     = "postgres"
}

variable "container_image" {
  type        = string
  description = "Postgres docker image"
  default     = "postgres:12-alpine"
}

variable "container_port" {
  type        = number
  description = "Postgres port"
  default     = 5432
}

variable "admin_user" {
  type        = string
  description = "Postgres admin user"
  default     = "postgres"
}

variable "resource_proxy" {
  type = object({
    cpu     = number,
    memory  = number
  })
  description = "Postgres proxy resources"
  default = {
    cpu         = 200
    memory      = 128
  }
  validation {
    condition     = var.resource_proxy.cpu >= 200 && var.resource_proxy.memory >= 128
    error_message = "Proxy resource must be at least: cpu=200, memory=128."
  }
}

variable "admin_password" {
  type        = string
  description = "Postgres admin password"
  default     = "postgres"
}

variable "database" {
  type        = string
  description = "Postgres database on init"
  default     = "metastore"
}

# https://github.com/docker-library/docs/blob/master/postgres/README.md#environment-variables
variable "container_environment_variables" {
  type        = list(string)
  description = "Postgres server environment variables"
  default     = ["PGDATA=/var/lib/postgresql/data"]
}

variable "volume_destination" {
  type        = string
  description = "Postgres volume destination"
  default     = "/var/lib/postgresql/data"
}

variable "use_host_volume" {
  type        = bool
  description = "Switch for nomad jobs to use host volume feature"
  default     = false
}

variable "use_canary" {
  type        = bool
  description = "Switch to use canary deployment for Postgres"
  default     = true
}

variable "vault_secret" {
  type = object({
    use_vault_provider      = bool,
    vault_kv_policy_name    = string,
    vault_kv_path           = string,
    vault_kv_field_username = string,
    vault_kv_field_password = string
  })
  description = "Set of properties to be able to fetch secret from vault"
  default = {
    use_vault_provider      = true
    vault_kv_policy_name    = "kv-secret"
    vault_kv_path           = "secret/data/postgres"
    vault_kv_field_username = "username"
    vault_kv_field_password = "password"
  }
}

variable "memory" {
  type        = number
  description = "Memory allocation for Postgres"
  default     = 428
}

variable "cpu" {
  type        = number
  description = "CPU allocation for Postgres"
  default     = 350
}
