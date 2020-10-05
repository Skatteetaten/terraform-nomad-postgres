<!-- markdownlint-disable MD041 -->
<p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>


# Terraform-nomad-postgres
This module is IaC - infrastructure as code which contains a nomad job of [postgres](https://www.postgresql.org/).

## Content
1. [Usage](#usage)
2. [Requirements](#requirements)
    1. [Required software](#required-software)
    2. [Providers](#providers)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Example usage](#example-usage)
    1. [Verifying setup](#verifying-setup)
6. [Volumes](#volumes)
7. [Vault secrets](#vault-secrets)
8. [License](#license)

## Usage
```text
make test
```
The command will run a standalone instance of postgres found in the [example](/example) folder.

## Requirements
### Required software
- [GNU make](https://man7.org/linux/man-pages/man1/make.1.html)
- [Docker](https://www.docker.com/)

### Providers
- [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs)

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nomad\_datacenters | Nomad data centers | list(string) | ["dc1"] | yes |
| nomad\_namespace | [Enterprise] Nomad namespace | string | "default" | yes |
| nomad\_host\_volume | Nomad host volume name | string | "persistence" | yes |
| service\_name | Postgres service name | string | "postgres" | yes |
| container\_port | Postgres port | number | 5432 | yes |
| container\_image | Postgres docker image | string | "postgres:12-alpine" | yes |
| admin\_user | Postgres admin username | string or data obj | data.vault_generic_secret.postgres_secrets.data.username | yes |
| admin\_password | Postgres admin password | string or data obj | data.vault_generic_secret.postgres_secrets.data.password | yes |
| admin\_password | Postgres database name | string | "metastore" | yes |
| container\_environment\_variables | Postgres container environement variables | list(string) | ["PGDATA=/var/lib/postgresql/data"] | yes |
| volume\_destination | Postgres volume destination | string | "/var/lib/postgresql/data" | yes |
| use\_host\_volume | Use nomad host volume | bool | false | yes< |

## Outputs
| Name | Description | Type |
|------|-------------|------|
| service\_name | Postgres service name | string |
| username | Postgres username | string |
| password | Postgres password | string |
| database\_name | Postgres database name | string |
| port | Postgres port | number |

## Example usage
The example-code shows the minimum of what you need to use this module.

```hcl-terraform
module "postgres" {
  source = "github.com/fredrikhgrelland/terraform-nomad-postgres.git?ref=0.0.2"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"
  nomad_host_volume = "persistence"

  # postgres
  service_name                    = "postgres"
  container_image                 = "postgres:12-alpine"
  container_port                  = 5432
  admin_user                      = "postgres"
  admin_password                  = "postgres"
  database                        = "metastore"
  volume_destination              = "/var/lib/postgresql/data"
  use_host_volume                 = true
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data"]
}
```

### Verifying setup
You can verify that postgres is running by checking the connection. This can be done using the `consul` docker image to set up a proxy. Check out the [required software](#required-software) section.
```shell script
make proxy-to-postgres
```

## Volumes
We are using [host volume](https://www.nomadproject.io/docs/job-specification/volume) to store postgres data.
If the `use_host_volume` is set to `true`, Postgres data will be available in root `/persistence/postgres` folder inside the Vagrant box.

## Vault secrets
The postgres username and password is generated and put in `/secret/postgres` inside Vault.

To get the username and password from Vault you can login to the [Vault-UI](http://localhost:8200/) with token `master` and reveal the username and password in `/secret/postgres`.
Alternatively, you can ssh into the vagrant box with `vagrant ssh`, and use the vault binary to get the username and password. See the following commands:
```sh
# get username
vault kv get -field='username' secret/postgres

# get password
vault kv get -field='password' secret/postgres
```

## License
This work is licensed under Apache 2 License. See [LICENSE](./LICENSE) for full details.
