terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 1.4.9"
    }
  }
  required_version = ">= 0.13"
}
