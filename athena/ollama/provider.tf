terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://100.91.212.59:8006/api2/json"
  pm_user         = "root@pam"
  pm_tls_insecure = true
  pm_password     = var.proxmox_password
}
