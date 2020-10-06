client {
  host_volume "persistence" {
    path = "/persistence/postgres"
    read_only = false
  }
}