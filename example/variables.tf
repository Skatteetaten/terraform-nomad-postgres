variable "nomad_acl" {
  type = bool
}

variable "username" {
  type        = string
  description = "Postgres username"
}

variable "password" {
  type        = string
  description = "Postgres password"
}