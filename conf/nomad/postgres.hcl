job "${service_name}" {

  type        = "service"
  datacenters = "${datacenters}"
  namespace   = "${namespace}"

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

  %{ if use_host_volume }
    volume "persistence" {
      type      = "host"
      source    = "${nomad_host_volume}"
      read_only = false
    }
  %{ endif }

    service {
      name = "${service_name}"
      port = "${port}"
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

    %{ if use_host_volume }
      volume_mount {
        volume      = "persistence"
        destination = "${volume_destination}"
        read_only   = false
      }
    %{ endif }

      config {
        image = "${image}"
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
${envs}
EOF
      }
    }
  }
}
