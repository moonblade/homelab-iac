resource "proxmox_vm_qemu" "windows" {
  vmid        = 402
  target_node = "hades"
  name        = "windows"
  desc        = "Windows 11 Desktop VM"
  bios        = "ovmf"
  machine     = "pc-q35-9.0"
  qemu_os     = "win11"
  cpu_type    = "host"
  cores       = 6
  sockets     = 1
  memory      = 12288
  balloon     = 0
  onboot      = false
  tablet      = true
  tags        = "windows,desktop"
  vm_state    = "running"
  scsihw      = "virtio-scsi-single"

  # EFI disk for OVMF/UEFI boot
  efidisk {
    efitype = "4m"
    storage = "local-lvm"
  }

  # Main OS disk
  disks {
    scsi {
      scsi0 {
        disk {
          size    = "100G"
          storage = "local-lvm"
          format  = "raw"
          ssd     = true
        }
      }
    }
  }

  # Network
  network {
    bridge = "vmbr0"
    model  = "virtio"
  }

  lifecycle {
    ignore_changes = [
      default_ipv4_address,
      ssh_host,
      ssh_port
    ]
  }
}

output "vm_name" {
  value       = "windows"
  description = "Windows 11 desktop VM"
}
