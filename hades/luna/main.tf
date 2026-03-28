module "nixos_desktop" {
  source = "../../terraform-modules/proxmox-vm-qemu"

  vmid        = 401
  target_node = "athena"
  name        = "luna"
  clone       = "nixos-base"
  cores       = 6
  sockets     = 1
  memory      = 8192
  desc        = "NixOS Desktop VM with i3, Sunshine streaming, and OpenCode"
  sshkeys     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
  ipv4_addr   = "192.168.1.199/24"
  ipv4_gw     = "192.168.1.1"
  disk_size   = "100G"
  password    = var.cipassword
  tags        = "desktop,nixos"
  vm_state    = "running"
}

variable "cipassword" {
  description = "Cloud-init password for the VM"
  type        = string
  sensitive   = true
}

output "vm_ip" {
  value       = "192.168.1.199"
  description = "Static IP address of the desktop VM"
}
