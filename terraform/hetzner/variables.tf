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

variable "github_owner" {
  type        = string
  default     = "stehessel"
  description = "The GitHub owner."
}

variable "github_token" {
  type        = string
  description = "The GitHub token."
  sensitive   = true
}

variable "repository_name" {
  type        = string
  default     = "infrastructure"
  description = "The GitHub repository name."
}

variable "repository_visibility" {
  type        = string
  default     = "private"
  description = "How visible is the github repo."
}

variable "branch" {
  type        = string
  default     = "master"
  description = "The branch name."
}

variable "target_path" {
  type        = string
  default     = "clusters/k3s"
  description = "Flux sync target path."
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "The infrastructure environment."
}
