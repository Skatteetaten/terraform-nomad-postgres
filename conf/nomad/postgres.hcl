job "${service_name}" {
  type        = "service"
  datacenters = ${datacenters}
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
      %{~ if use_static_port ~}
      port "psql" { static = ${port} }
      %{~ else ~}
      port "psql" { to = ${port} }
      %{~ endif ~}
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
      port = "psql"
      tags = ${consul_tags}
      check {
        type      = "script"
        task      = "postgresql"
        command   = "${pg_isready_path}"
      %{~ if use_vault_provider ~}
        args      = ["-U", "$POSTGRES_USER"]
      %{~ else ~}
        args      = ["-U", "${username}"]
      %{~ endif ~}
        interval  = "30s"
        timeout   = "2s"
      }

      %{ if use_connect }
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
      %{ endif }
    }

    task "postgresql" {
      driver = "docker"
    %{~ if use_vault_provider ~}
      vault {
        policies = "${vault_kv_policy_name}"
      }
    %{~ endif ~}

    %{~ if use_host_volume ~}
      volume_mount {
        volume      = "persistence"
        destination = "${volume_destination}"
        read_only   = false
      }
    %{~ endif ~}

      config {
        image      = "${image}"
      %{~ if entrypoints != "[]" ~}
        entrypoint = ${entrypoints}
      %{~ endif ~}
      %{~ if command != "" ~}
        command    = "${command}"
      %{~ endif ~}
      %{~ if command_args != "[]" ~}
        args       = ${command_args}
      %{~ endif ~}
      }

      logs {
        max_files     = 10
        max_file_size = 2
      }

      template {
        destination = "secrets/.envs"
        change_mode = "noop"
        env         = true
        data        = <<EOF
%{ if use_vault_provider }
{{ with secret "${vault_kv_path}" }}
POSTGRES_USER="{{ .Data.data.${vault_kv_field_username} }}"
POSTGRES_PASSWORD="{{ .Data.data.${vault_kv_field_password} }}"
{{ end }}
%{ else ~}
POSTGRES_USER="${username}"
POSTGRES_PASSWORD="${password}"
%{ endif ~}
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
