variable "hcloud_ssh_public_key_file" {
  type        = string
  default     = "/run/secrets/ssh/hcloud/public"
  description = "File containing the SSH public key."
}

variable "hcloud_ssh_private_key_file" {
  type        = string
  default     = "/run/secrets/ssh/hcloud/private"
  description = "File containing the SSH private key."
}
