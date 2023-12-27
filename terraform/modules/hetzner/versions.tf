terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0.0"
    }
  }
  cloud {
    organization = "stehessel"
    workspaces {
      name = "homelab"
    }
  }
}
