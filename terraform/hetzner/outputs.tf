output "kubeconfig" {
  description = "The kubeconfig file to access the cluster via kubectl."
  sensitive   = true
  value       = module.kube-hetzner.kubeconfig_file
}

output "ingress_public_ipv4" {
  description = "The public IPv4 address of the Hetzner load balancer."
  value       = module.kube-hetzner.ingress_public_ipv4
}

output "ingress_public_ipv6" {
  description = "The public IPv6 address of the Hetzner load balancer."
  value       = module.kube-hetzner.ingress_public_ipv6
}

output "control_planes_public_ipv4" {
  description = "The IPv4 addresses of all control plane nodes."
  value       = module.kube-hetzner.control_planes_public_ipv4
}

output "agents_public_ipv4" {
  description = "The IPv4 addresses of all agent nodes."
  value       = module.kube-hetzner.agents_public_ipv4
}
