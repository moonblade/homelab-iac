locals {
  ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
}

module "nixos_desktop" {
  source = "../../terraform-modules/proxmox-vm-qemu"

  vmid        = 402
  target_node = "athena"
  name        = "terra"
  clone       = "nixos-base"
  cores       = 4
  sockets     = 1
  memory      = 14336
  balloon     = 0
  desc        = "NixOS Desktop VM (i3 + xrdp) - smaller backup for Luna, no GPU. Used when Hades is down."
  sshkeys     = local.ssh_pubkey
  ipv4_addr   = "192.168.1.200/24"
  ipv4_gw     = "192.168.1.1"
  disk_size   = "80G"
  password    = var.cipassword
  tags        = "desktop,nixos,backup"
  vm_state    = "running"
}

variable "cipassword" {
  description = "Cloud-init password for the VM"
  type        = string
  sensitive   = true
}

output "vm_ip" {
  value       = "192.168.1.200"
  description = "Static IP address of the desktop VM"
}
