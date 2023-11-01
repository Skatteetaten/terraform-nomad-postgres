<!-- markdownlint-disable MD041 -->
<p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>


# Terraform-nomad-postgres
This module is IaC - infrastructure as code which contains a nomad job of [postgres](https://www.postgresql.org/).

## Content
1. [Requirements](#requirements)
    1. [Required modules](#required-modules)
    2. [Required software](#required-software)
2. [Usage](#usage)
    1. [Verifying setup](#verifying-setup)
    2. [Intentions](#intentions)
    3. [Providers](#providers)
3. [Example usage](#example-usage)
4. [Inputs](#inputs)
5. [Outputs](#outputs)
6. [Secrets & credentials](#secrets--credentials)
    1. [Set credentials manually](#set-credentials-manually)
    2. [Set credentials using Vault secrets](#set-credentials-using-vault-secrets)
7. [Volumes](#volumes)
8. [Contributors](#contributors)
9. [License](#license)

## Requirements

### Required modules
No required modules.

### Required software
- [GNU make](https://man7.org/linux/man-pages/man1/make.1.html)
- [Docker](https://www.docker.com/)
- [Consul](https://releases.hashicorp.com/consul/)
- [psql CLI](https://www.postgresqltutorial.com/install-postgresql/)

## Usage
The following command will run a standalone instance of postgres found in the [example](/example) folder.

```sh
make test
```

### Verifying setup
You can verify that Postgres is running by checking the connection. The following command uses Consul ([required software](#required-software)) to set up a proxy.
```sh
make proxy
```

Further, you can verify the connection by connecting with the psql CLI ([required software](#required-software)) using the command below.
You can find the `username` and `password` in the [Vault UI (localhost:8200)](http://localhost:8200/).
```sh
psql "dbname=metastore host=127.0.0.1 user=<username> password=<password> port=5432 sslmode=disable"
```

### Intentions
The intentions in the table below will need to be put in place if you are going to use this module in a hashistack ecosystem, we have done so in our vagrantbox example ([00_create_intetion.yml](dev/ansible/00_create_intention.yml)).

| Intention between | type |
| :---------------- | :--- |
| postgres-local => postgres  | allow |

> :warning: Note that these intentions needs to be created if you are using the module in another module.

### Providers
- [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs)

## Example usage
The example-code shows some of the variables you need to provide to use this module. See the [postgres_standalone](example/postgres_standalone) example for more details.

```hcl-terraform
module "postgres" {
  source = "github.com/fredrikhgrelland/terraform-nomad-postgres.git?ref=0.2.0"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"
  nomad_host_volume = "persistence"

  # postgres
  service_name                    = "postgres"
  container_image                 = "postgres:12-alpine"
  container_port                  = 5432
  vault_secret                    = {
                                      use_vault_provider      = false,
                                      vault_kv_path           = "",
                                      vault_kv_policy_name    = "",
                                      vault_kv_field_username = "",
                                      vault_kv_field_password = ""
                                    }
  admin_user                      = "postgres"
  admin_password                  = "postgres"
  database                        = "metastore"
  volume_destination              = "/var/lib/postgresql/data"
  nomad_host_volume               = "/local/postgres"
  use_canary                      = false
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data/"]
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nomad_datacenters | Nomad data centers | list(string) | ["*"] | no |
| nomad_namespace | [Enterprise] Nomad namespace | string | "default" | no |
| nomad_host_volume | Nomad host volume name | string | "" | no |
| nomad_csi_volume | Nomad CSI volume name to mount | string | "" | no |
| nomad_csi_volume_extra | Extra config to inject in Nomad's CSI volume stanza | string | "" | no |
| nomad_job_extra | Extra config to inject in Nomad's job config stanza | string | "" | no |
| nomad_group_extra | Extra config to inject in Nomad's group config stanza | string | "" | no |
| nomad_task_extra | Extra config to inject in Nomad's task config stanza | string | "" | no |
| nomad_docker_config_extra | Extra config to inject in Nomad's docker config stanza | string | "" | no |
| consul_tags | List of one or more tags to announce in Consul, for service discovery purposes | list(string) | [""] | no |
| service_name | Postgres service name | string | "postgres" | no |
| container_image | Postgres docker image | string | "postgres:12-alpine" | no |
| container_entrypoints | Docker driver entrypoint array | list(string) | no |
| container_command | Docker driver command string | string | no |
| container_command_args | Docker driver command args array | list(string) | no |
| container_port | Postgres port | number | 5432 | no |
| use_static_port | Switch to make container_port static | bool | false | no |
| admin_user | Postgres admin username | string | "postgres" | no |
| admin_password | Postgres admin password | string | "postgres" | no |
| database | Postgres database name | string | "metastore" | no |
| pg_isready_path | Path to `pg_isready` script for health checks" | string | "/usr/local/bin/pg_isready" | no |
| container_environment_variables | Postgres container environement variables | list(string) | ["PGDATA=/var/lib/postgresql/data"] | no |
| volume_destination | Postgres volume destination | string | "/var/lib/postgresql/data" | no |
| use_host_volume | Use nomad host volume | bool | false | no |
| use_canary | Switch to use canary deployment for Postgres | bool | true | no |
| use_connect | Use Consul Connect | bool | true | no |
| vault_secret.use_vault_provider | Set if want to access secrets from Vault | bool | false | no |
| vault_secret.vault_kv_policy_name | Vault policy name to read secrets | string | "kv-secret" | no |
| vault_secret.vault_kv_path | Path to the secret key in Vault | string | "secret/data/postgres" | no |
| vault_secret.vault_kv_field_username | Secret key name in Vault kv path | string | "username" | no |
| vault_secret.vault_kv_field_password | Secret key name in Vault kv path | string | "password" | no |
| memory | Memory allocation for Postgres in MB | number | 428 | no |
| cpu | CPU allocation for Postgres in MHz | number | 350 | no |
| resource_proxy | Resource allocations for proxy | obj(number, number) |	{ <br> cpu = 200, <br> memory = 128 <br> } |	no |
 	
## Outputs
| Name | Description | Type |
|------|-------------|------|
| service_name | Postgres service name | string |
| username | Postgres username | string |
| password | Postgres password | string |
| database_name | Postgres database name | string |
| port | Postgres port | number |

## Secrets & credentials
This module presents two ways of setting credentials (username and password). You can set them manually or upload secrets to Vault.

### Set credentials manually
To set the credentials manually you first need to tell the module to not fetch credentials from vault. To do that, set `vault_secret.use_vault_provider` to `false` (see below for example). If this is done the module will use the variables `admin_user` and `admin_password` to set the postgres credentials. These will default to `postgres` if not set by the user.  
Below is an example on how to disable the use of vault credentials, and setting your own credentials.

```hcl-terraform
module "postgres" {
...

  vault_secret  = {
                    use_vault_provider      = false,
                    vault_kv_path           = "",
                    vault_kv_field_username = "",
                    vault_kv_field_password = ""
                  }
  admin_user     = "myadminuser"     # default 'postgres'
  admin_password = "myadminpassword" # default 'postgres'
}
```

### Set credentials using Vault secrets
By default `use_vault_provider` is set to `false`. 
However, when testing using the box (e.g. `make dev`) the postgres username and password is randomly generated and put in `secret/postgres` inside Vault, from the [01_generate_secrets_vault.yml](dev/ansible/01_generate_secrets_vault.yml) playbook. 
This is an independent process and will run regardless of the `vault_secret.use_vault_provider` is `false/true`.

If you want to use the automatically generated credentials in the box, you can do so by changing the `vault_secret` object as seen below:
```hcl-terraform
module "postgres" {
...

  vault_secret  = {
                    use_vault_provider      = true,
                    vault_kv_policy_name    = "kv-secret"
                    vault_kv_path           = "secret/postgres",
                    vault_kv_field_username = "username",
                    vault_kv_field_password = "password"
                  }
}
```

If you want to change the secrets path and keys/values in Vault with your own configuration you would need to change the variables in the `vault_secret`-object. 
Say that you have put your secrets in `secret/services/postgres/users` and change the keys to `guestuser` and `guestpassword`. Then you need to do the following configuration:
```hcl-terraform
module "postgres" {
...

  vault_secret  = {
                    use_vault_provider      = true,
                    vault_kv_policy_name    = "kv-users-secret"
                    vault_kv_path           = "secret/services/postgres/users",
                    vault_kv_field_username = "guestuser",
                    vault_kv_field_password = "guestpassword"
                  }
}
```

## Volumes
Module (optionally) supports [host volume](https://www.nomadproject.io/docs/job-specification/volume) to store postgres data.
If the `use_host_volume` is set to `true` (default: false), Postgres data will be available in root `/persistence/postgres` folder inside the Vagrant box.

## Contributors
[<img src="https://avatars0.githubusercontent.com/u/40291976?s=64&v=4">](https://github.com/fredrikhgrelland)
[<img src="https://avatars2.githubusercontent.com/u/29984156?s=64&v=4">](https://github.com/claesgill)
[<img src="https://avatars3.githubusercontent.com/u/15572799?s=64&v=4">](https://github.com/zhenik)
[<img src="https://avatars3.githubusercontent.com/u/67954397?s=64&v=4">](https://github.com/Neha-Sinha2305)
[<img src="https://avatars3.githubusercontent.com/u/71001093?s=64&v=4">](https://github.com/dangernil)
[<img src="https://avatars1.githubusercontent.com/u/51820995?s=64&v=4">](https://github.com/pdmthorsrud)

## License
This work is licensed under Apache 2 License. See [LICENSE](./LICENSE) for full details.
