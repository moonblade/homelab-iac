module "k3svm" {
  source = "../../terraform-modules/proxmox-vm-qemu"

  vmid        = 301
  target_node = "athena"
  name        = "sirius"
  clone       = "nixos-base"
  cores       = 6
  memory      = 12288
  desc        = "VM for k3s"
  sshkeys     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
  ipv4_addr   = "192.168.1.150/24"
  ipv4_gw     = "192.168.1.1"
  disk_size   = "100G"
  # additional_disk_size = "500G"
  # additional_disk_storage = "external"
  tags        = "k3s"
  vm_state    = "started"
}
