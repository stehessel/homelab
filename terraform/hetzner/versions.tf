terraform {
  required_version = ">= 1.3.3"
  required_providers {
    # Hetzner
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.38.2"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7.2"
    }
  }
  cloud {
    organization = "stehessel"
    workspaces {
      name = "homelab"
    }
  }
}
