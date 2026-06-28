locals {
  ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
}

module "nixos_desktop" {
  source = "../../terraform-modules/proxmox-vm-qemu"

  vmid        = 401
  target_node = "hades"
  name        = "luna"
  clone       = "nixos-base"
  cores       = 6
  sockets     = 1
  memory      = 24576
  balloon     = 0
  desc        = "NixOS Desktop VM with i3, Sunshine streaming, OpenCode, and Ollama (NVIDIA GPU)"
  sshkeys     = local.ssh_pubkey
  ipv4_addr   = "192.168.1.199/24"
  ipv4_gw     = "192.168.1.1"
  disk_size   = "100G"
  password    = var.cipassword
  tags        = "desktop,nixos,gpu,ollama"
  vm_state    = "running"

  # NVIDIA GPU passthrough (moved from Windows VM 202)
  # GPU: NVIDIA (10de:2d04) + Audio (10de:22eb) at 0000:01:00
  # Requires: vfio-pci bound on host, IOMMU enabled (AMD-Vi)
  # machine = "q35"  # Q35 required for PCIe passthrough (managed outside Terraform)
  # hostpci0 = "0000:01:00,pcie=1,x-vga=0"  # Set via: qm set 401 --hostpci0 0000:01:00,pcie=1,x-vga=0
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
