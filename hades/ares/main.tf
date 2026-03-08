module "nixos_desktop" {
  source = "../../terraform-modules/proxmox-vm-qemu"

  vmid        = 402
  target_node = "hades"
  name        = "ares"
  clone       = "nixos-base"
  cores       = 2
  memory      = 4096
  desc        = "NixOS VM with i3 - SSH-focused development machine for opencode/openclaw"
  sshkeys     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
  ipv4_addr   = "192.168.1.197/24"
  ipv4_gw     = "192.168.1.1"
  disk_size   = "100G"
  password    = var.cipassword
  tags        = "nixos,dev"
  vm_state    = "running"
}

variable "cipassword" {
  description = "Cloud-init password for the VM"
  type        = string
  sensitive   = true
}

output "vm_ip" {
  value       = "192.168.1.197"
  description = "Static IP address of the ares VM"
}
