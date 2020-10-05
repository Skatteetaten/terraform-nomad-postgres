# terraform-nomad-postgres

```text
make test
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nomad\_host\_volume | Nomad host volume name | string | "persistence" | No |
| volume\_destination | Postgres volume destination | string | "/var/lib/postgresql/data" | No |
| use\_host\_volume | Use nomad host volume | bool | false | No |

## Volumes
We are using [host volume](https://www.nomadproject.io/docs/job-specification/volume) to store postgres data.
If the `use_host_volume` is set to `true`, Postgres data will be available in root `/persistence/postgres` folder inside the Vagrant box.

## Vault secrets
The postegres username and password is generated and put in `/secret/postgres` inside Vault.

To get the username and password from Vault you can login to the [Vault-UI](http://localhost:8200/) with token `master` and reveal the username and password in `/secret/postgres`.
Alternatively, you can ssh into the vagrant box with `vagrant ssh`, and use the vault binary to get the username and password. See the following commands:
```sh
# get username
vault kv get -field='username' secret/postgres

# get password
vault kv get -field='password' secret/postgres
```