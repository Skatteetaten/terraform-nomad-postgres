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
}

variable "admin_password" {
  type        = string
  description = "Postgres admin password"
}

variable "database" {
  type        = string
  description = "Postgres database on init"
}

# https://github.com/docker-library/docs/blob/master/postgres/README.md#environment-variables
variable "container_environment_variables" {
  type        = list(string)
  description = "Postgres server environment variables"
  default     = ["PGDATA=/var/lib/postgresql/data"]
}

