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

    volume "persistence-point-to-tmp2" {
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
        volume      = "persistence-point-to-tmp2"
        destination = "/var/lib/postgresql/"
        read_only   = false
      }

      config {
        image = "postgres:12-alpine"
//        volumes = ["postgres/:/postgres/"]

//        command = "/bin/bash"
//        args = [
//          "-c",
//          "mkdir /var/lib/postgresql/data/pgdata && echo \"Succ\" || echo \"Failed 1\"",
//          "mkdir /var/lib/postgresql/data/lul && echo \"Succ\" || echo \"Failed 1\"",
////          "chomod -R a+rwx /var/lib/postgresql/data/pgdata"
//          ]
//          "echo \"Hello World\" > file1.txt && echo \"Success\" || echo \"Failed\""
//          "echo \"while true; do cp -R /var/lib/postgresql/data/pgdata var/lib/postgresql && echo \"Sucsess copying\" || echo \"Failed copying\"; sleep 5; done\" > script.sh",
//          "sh script.sh &"
////          "chmod -R a+rwx /var/lib/postgresql/data/ && echo \"Success chmod\" || echo \"Error chmod\"",
////          "mkdir var/lib/postgresql/test_pgdata",
//          "for VAL in {1..5}; do cp -R /var/lib/postgresql/data/pgdata var/lib/postgresql && echo \"Sucsess copying $VAL\" || echo \"Failed copying $VAL\"; sleep 5; done",
//          "&"
//        ]
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
PGDATA=/var/lib/postgresql
EOF
      }
    }
  }
}
