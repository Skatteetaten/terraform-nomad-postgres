# terraform-nomad-postgres

```text
make test
```

## Volumes
We are using [host volume](https://www.nomadproject.io/docs/job-specification/volume) to store postgres data.
Postgres data will now be available in the `persistence/postgres` folder.
