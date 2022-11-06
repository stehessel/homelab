data "sops_file" "secrets" {
  source_file = "secrets/prod.yaml"
}

module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }
  hcloud_token = data.sops_file.secrets.data["hcloud.token"]

  source = "kube-hetzner/kube-hetzner/hcloud"

  ssh_public_key  = file("/run/secrets/ssh/hcloud/public")
  ssh_private_key = file("/run/secrets/ssh/hcloud/private")

  network_region = "eu-central"

  control_plane_nodepools = [
    {
      name        = "control-plane-nbg1",
      server_type = "cpx11",
      location    = "nbg1",
      labels      = [],
      taints      = [],
      count       = 1
    }
  ]

  agent_nodepools = [
    {
      name        = "agent-nbg1",
      server_type = "cpx11",
      location    = "nbg1",
      labels = [
        "node.kubernetes.io/server-usage=storage"
      ],
      taints = [],
      count  = 1
    }
  ]

  load_balancer_type     = "lb11"
  load_balancer_location = "nbg1"

  base_domain = "hesselmann.cloud"

  enable_longhorn        = true
  longhorn_replica_count = 1

  allow_scheduling_on_control_plane = true

  automatically_upgrade_os = false

  initial_k3s_channel = "v1.24"

  # Don't create a local kubeconfig file. For backwards compatibility this is set to true by default in the module but for automatic runs this can cause issues.
  # See https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/issues/349
  # The kubeconfig file can instead be created by executing: "terraform output --raw kubeconfig > cluster_kubeconfig.yaml"
  # Be careful to not commit this file!
  create_kubeconfig = false
}

provider "hcloud" {
  token = data.sops_file.secrets.data["hcloud.token"]
}

terraform {
  required_version = ">= 1.2.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.35.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
  }
  backend "s3" {
    bucket                      = "terraform-backend"
    endpoint                    = "s3.us-west-000.backblazeb2.com"
    key                         = "terraform.tfstate"
    region                      = "us-east-1" # meaningless, but the provider needs it. It can be any string
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig_file
  sensitive = true
}
