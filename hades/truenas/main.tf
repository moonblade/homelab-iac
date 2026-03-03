# TrueNAS SCALE Configuration
# Host: 192.168.1.10 (Hades Proxmox VM)
# Version: TrueNAS SCALE 25.10.1 (Fangtooth)
#
# This Terraform configuration documents the existing TrueNAS setup.
# Pools are created manually via TrueNAS UI (cannot be managed by Terraform).
#
# Storage Layout:
# - primary (10TB) - Main storage pool (sdc)
# - secondary (2TB) - Secondary storage pool (sdd)  
# - apps (100GB) - Application data pool (sda)

locals {
  # Pool information (for reference - pools managed via TrueNAS UI)
  pools = {
    primary = {
      size_tb = 10
      disk    = "sdc"
      path    = "/mnt/primary"
    }
    secondary = {
      size_tb = 2
      disk    = "sdd"
      path    = "/mnt/secondary"
    }
    apps = {
      size_gb = 100
      disk    = "sda"
      path    = "/mnt/apps"
    }
  }
}
