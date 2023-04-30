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
  backend "s3" {
    bucket                      = "terraform-backend"
    endpoint                    = "s3.us-west-000.backblazeb2.com"
    key                         = "terraform.tfstate"
    region                      = "us-east-1" # Meaningless, but the provider needs it. It can be any string.
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
