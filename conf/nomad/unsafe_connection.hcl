job "ingress-example" {

  datacenters = ["dc1"]

  group "ingress-group" {

    network {
      mode = "bridge"

      port "inbound" {
        static = 4567
      }
    }

    service {
      name = "ingress-service"
      port = "8081"

      connect {
        gateway {
          proxy {
            // Consul Gateway Proxy configuration options
            connect_timeout = "500ms"
          }
          ingress {
            // Consul Ingress Gateway Configuration Entry
            tls {
              enabled = false
            }

            listener {
              port = 4567
              protocol = "tcp"
              service {
                name = "postgres"
              }
            }
          }
        }
      }
    }
  }
}