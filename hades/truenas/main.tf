# TrueNAS SCALE Configuration
# Host: 192.168.1.10 (Hades Proxmox VM)
# Version: TrueNAS SCALE 25.10.1 (Fangtooth)
#
# This Terraform configuration documents the existing TrueNAS setup.
# Pools are created manually via TrueNAS UI (cannot be managed by Terraform).
#
# Storage Layout:
# - primary (10TB) - Main storage pool (sata)
# - secondary (2TB) - Secondary storage pool (sata)  
# - apps (100GB) - Application data pool (local-lvm)
# - usb-ssd (931GB) - USB SanDisk Extreme SSD (media/downloads)
# - usb-hdd (931GB) - USB 1TB HDD (media/downloads)

locals {
  # Pool information (for reference - pools managed via TrueNAS UI)
  pools = {
    primary = {
      size_tb = 10
      disk    = "sata"
      path    = "/mnt/primary"
    }
    secondary = {
      size_tb = 2
      disk    = "sata"
      path    = "/mnt/secondary"
    }
    apps = {
      size_gb = 100
      disk    = "local-lvm"
      path    = "/mnt/apps"
    }
    usb-ssd = {
      size_gb = 931
      disk    = "usb"
      path    = "/mnt/usb-ssd"
      note    = "SanDisk Extreme SSD via USB passthrough"
    }
    usb-hdd = {
      size_gb = 931
      disk    = "usb"
      path    = "/mnt/usb-hdd"
      note    = "1TB HDD via USB passthrough"
    }
  }
}

# Enable SSH service for remote management
resource "truenas_ssh_config" "ssh" {
  passwordauth = true
}

resource "truenas_service_started" "ssh" {
  service = "ssh"
}

# Root user with SSH key for remote access
# Import with: terraform import truenas_user.root 1
resource "truenas_user" "root" {
  username  = "root"
  full_name = "root"
  sshpubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
}

# Fix root folder permissions for NFS and rsync access
resource "truenas_filesystem_setperm" "root_perms" {
  path             = "/mnt/primary/root"
  mode             = "755"
  options_stripacl = true
}

# Fix config folder permissions for NFS access
resource "truenas_filesystem_setperm" "config_perms" {
  path             = "/mnt/primary/root/config"
  mode             = "755"
  options_stripacl = true

  depends_on = [truenas_filesystem_setperm.root_perms]
}
