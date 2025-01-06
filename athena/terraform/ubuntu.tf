module "ubuntuvm" {
  for_each = toset([])
  source = "../../terraform-modules/proxmox-vm-qemu"

  vmid        = 302
  target_node = "athena"
  name        = "ubuntu"
  clone       = "ubuntu-base"
  cores       = 6
  memory      = 8192
  desc        = "Ubuntu VM for general purpose"
  sshkeys     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
  ipv4_addr   = "192.168.1.151/24"
  ipv4_gw     = "192.168.1.1"
  disk_size   = "100G"
  additional_disk_size = "300G"
  additional_disk_storage = "external"
  tags        = "vm"
  vm_state    = "started"
}
