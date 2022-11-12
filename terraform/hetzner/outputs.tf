output "kubeconfig" {
  value       = module.kube-hetzner.kubeconfig_file
  sensitive   = true
  description = "The kubeconfig file to access the cluster via kubectl."
}

output "control_planes_public_ipv4" {
  value       = module.kube-hetzner.control_planes_public_ipv4
  description = "The IPv4 addresses of all control plane nodes."
}

output "agents_public_ipv4" {
  value       = module.kube-hetzner.agents_public_ipv4
  description = "The IPv4 addresses of all agent nodes."
}
