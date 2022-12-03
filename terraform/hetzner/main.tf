data "sops_file" "secrets" {
  source_file = "secrets/base.yaml"
}

provider "hcloud" {
  token = data.sops_file.secrets.data["hcloud.token"]
}

module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }
  hcloud_token = data.sops_file.secrets.data["hcloud.token"]

  source = "kube-hetzner/kube-hetzner/hcloud"

  ssh_public_key  = file(var.hcloud_ssh_public_key_file)
  ssh_private_key = file(var.hcloud_ssh_private_key_file)

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
      server_type = "cpx21",
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

  base_domain = "stehessel.org"

  enable_traefik = false

  enable_metrics_server = false

  enable_longhorn        = true
  longhorn_replica_count = 1

  allow_scheduling_on_control_plane = false

  automatically_upgrade_os = false

  initial_k3s_channel = "v1.24"

  enable_cert_manager = true

  cert_manager_values = <<EOT
installCRDs: true
featureGates: ExperimentalGatewayAPISupport=true
  EOT

  # Don't create a local kubeconfig file. For backwards compatibility this is set to true by default in the module but for automatic runs this can cause issues.
  # See https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/issues/349
  # The kubeconfig file can instead be created by executing: "terraform output --raw kubeconfig > cluster_kubeconfig.yaml"
  # Be careful to not commit this file!
  create_kubeconfig = false
}

provider "porkbun" {
  api_key    = data.sops_file.secrets.data["porkbun.apiKey"]
  secret_key = data.sops_file.secrets.data["porkbun.secretKey"]
}


# resource "porkbun_dns_record" "baseIPv4" {
#   name    = ""
#   domain  = "stehessel.org"
#   content = module.kube-hetzner.ingress_public_ipv4
#   type    = "A"
# }
#
# resource "porkbun_dns_record" "starIPv4" {
#   name    = "*"
#   domain  = "stehessel.org"
#   content = module.kube-hetzner.ingress_public_ipv4
#   type    = "A"
# }
#
# resource "porkbun_dns_record" "baseIPv6" {
#   name    = ""
#   domain  = "stehessel.org"
#   content = module.kube-hetzner.ingress_public_ipv6
#   type    = "AAAA"
# }
#
# resource "porkbun_dns_record" "starIPv6" {
#   name    = "*"
#   domain  = "stehessel.org"
#   content = module.kube-hetzner.ingress_public_ipv6
#   type    = "AAAA"
# }
