resource "proxmox_lxc" "this" {
  vmid         = var.vmid
  target_node  = var.target_node
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  password     = var.password
  unprivileged = var.unprivileged
  onboot       = true
  start        = true
  cores        = var.cores
  memory       = var.memory
  swap         = var.swap
  tags         = var.tags

  ssh_public_keys = var.sshkeys

  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = var.ipv4_addr
    gw     = var.ipv4_gw
  }

  nameserver = var.nameserver

  features {
    nesting = var.nesting
  }

  lifecycle {
    ignore_changes = [
      rootfs
    ]
  }
}
