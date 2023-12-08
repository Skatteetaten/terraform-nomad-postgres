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
      %{~ if nomad_network_mode != "" ~}
      mode = "${nomad_network_mode}"
      %{~ endif ~}
      port "psql" {
      %{~ if nomad_host_network != "" ~}
        host_network = "${nomad_host_network}"
      %{~ endif ~}
      %{~ if use_static_port ~}
        static = ${port}
      %{~ else ~}
        to = ${port}
      %{~ endif ~}
      }
    }

  %{~ if nomad_host_volume != "" ~}
    volume "persistence" {
      type      = "host"
      source    = "${nomad_host_volume}"
      read_only = false
    }
  %{~ endif }
  %{~ if nomad_csi_volume != "" && nomad_host_volume == "" ~}
    volume "persistence" {
      type      = "csi"
      source    = "${nomad_csi_volume}"
      read_only = false
    %{~ if nomad_csi_volume_extra != "" ~}
${nomad_csi_volume_extra}
    %{~ endif ~}
    }
  %{~ endif ~}

    service {
      provider = "${service_provider}"
      name = "${service_name}"
      port = "psql"
      tags = ${service_tags}
      %{~ if service_provider == "consul" ~}
      check {
        type      = "script"
        task      = "postgresql"
        command   = "${pg_isready_path}"
        interval  = "30s"
        timeout   = "2s"
      }
      %{~ endif ~}
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

    %{~ if nomad_host_volume != "" ~}
      volume_mount {
        volume      = "persistence"
        destination = "${volume_destination}"
        read_only   = false
      }
    %{~ endif ~}
    %{~ if nomad_csi_volume != "" && nomad_host_volume == "" ~}
      volume_mount {
        volume      = "persistence"
        destination = "${volume_destination}"
        read_only   = false
      }
    %{ endif ~}

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
      %{~ if nomad_docker_network_mode != "" ~}
        network_mode = "${nomad_docker_network_mode}"
      %{~ endif ~}
      %{~ if docker_config_extra != "" ~}
${docker_config_extra}
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
    %{~ if task_extra != "" ~}
${task_extra}
    %{~ endif ~}
    }
  %{~ if group_extra != "" ~}
${group_extra}
  %{~ endif ~}
  }
}
