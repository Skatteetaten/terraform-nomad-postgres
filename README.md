# terraform-nomad-postgres

```text
make test
```

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
