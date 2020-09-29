job "postgres" {

  type        = "service"
  datacenters = ["dc1"]
  namespace   = "default"

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "10m"
    progress_deadline = "12m"
    auto_revert       = true
    auto_promote      = true
    canary            = 1
    stagger           = "30s"
  }

  group "database" {

    network {
      mode = "bridge"
    }

    volume "persistence" {
      type      = "host"
      source    = "persistence"
      read_only = false
    }


    service {
      name = "postgres"
      port = 5432
      check {
        type      = "script"
        task      = "postgresql"
        command   = "/usr/local/bin/pg_isready"
        args      = ["-U", "$POSTGRES_USER"]
        interval  = "30s"
        timeout   = "2s"
      }

      connect {
        sidecar_service {}
      }

    }

    task "postgresql" {
      driver = "docker"

      volume_mount {
        volume      = "persistence"
        destination = "/var/lib/postgresql/data/"
        read_only   = false
      }

      config {
        image = "postgres:12-alpine"
      }

      logs {
        max_files     = 10
        max_file_size = 2
      }


      template {
        destination = "local/secrets/.envs"
        change_mode = "noop"
        env         = true
        data        = <<EOF
POSTGRES_DB="hive"
POSTGRES_USER="hive"
POSTGRES_PASSWORD="hive"
PGDATA="/var/lib/postgresql/data/pgdata"
EOF
      }
    }
  }
}
