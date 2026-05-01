module "ollama_lxc" {
  source = "../../terraform-modules/proxmox-lxc"

  vmid         = 102
  target_node  = "athena"
  hostname     = "ollama"
  ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password     = var.container_password
  cores        = 4
  memory       = 12288
  swap         = 1024
  rootfs_size  = "30G"
  ipv4_addr    = "192.168.1.198/24"
  ipv4_gw      = "192.168.1.1"
  sshkeys      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
  tags         = "ollama;lxc"
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
  value       = "192.168.1.198"
  description = "Static IP address of the Ollama LXC container"
}
