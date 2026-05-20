locals {
  ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
}

module "ollama_lxc" {
  source = "../../terraform-modules/proxmox-lxc"

  vmid         = 501
  target_node  = "hades"
  hostname     = "ollama"
  ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password     = var.container_password
  cores        = 8
  memory       = 16384
  swap         = 1024
  rootfs_size  = "30G"
  ipv4_addr    = "192.168.1.74/24"
  ipv4_gw      = "192.168.1.1"
  sshkeys      = local.ssh_pubkey
  tags         = "ollama;lxc;gpu"
}

variable "proxmox_password" {
  description = "Proxmox root password"
  type        = string
  sensitive   = true
}

variable "container_password" {
  description = "LXC container root password"
  type        = string
  sensitive   = true
}

output "container_ip" {
  value       = "192.168.1.74"
  description = "Static IP address of the Ollama LXC container"
}
