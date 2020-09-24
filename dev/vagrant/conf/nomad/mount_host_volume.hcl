client {
  host_volume "persistence" {
    path = "/vagrant/persistence/postgres"
    read_only = false
  }
}