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
    stagger           = "30s"
  %{ if use_canary }
    canary            = 1
    auto_revert       = true
    auto_promote      = true
  %{ endif }
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
      %{ if use_vault_provider }
        args      = ["-U", "$POSTGRES_USER"]
      %{ else }
        args      = ["-U", "${username}"]
      %{ endif }
        interval  = "30s"
        timeout   = "2s"
      }

      connect {
        sidecar_service {
        }

        sidecar_task {
          resources {
            cpu = "${cpu_proxy}"
            memory = "${memory_proxy}"
          }
        }
      }
    }

    task "postgresql" {
      driver = "docker"
    %{ if use_vault_provider }
      vault {
        policies = "${vault_kv_policy_name}"
      }
    %{ endif }

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
%{ if use_vault_provider }
{{ with secret "${vault_kv_path}" }}
POSTGRES_USER="{{ .Data.data.${vault_kv_field_username} }}"
POSTGRES_PASSWORD="{{ .Data.data.${vault_kv_field_password} }}"
{{ end }}
%{ else }
POSTGRES_USER="${username}"
POSTGRES_PASSWORD="${password}"
%{ endif }
${envs}
EOF
      }

      resources {
        memory = "${memory}"
        cpu    = "${cpu}"
      }
    }
  }
}
