terraform {
  required_version = ">= 1.5.0"
  cloud {
    organization = "stehessel"
    workspaces {
      name = "homelab"
    }
  }
}
