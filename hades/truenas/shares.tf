resource "truenas_sharing_smb" "root" {
  name      = "root"
  path      = "/mnt/primary/root"
  enabled   = true
  readonly  = false
  browsable = true
}

resource "truenas_sharing_smb" "audiobooks" {
  name      = "audiobooks"
  path      = "/mnt/primary/root/audiobooks"
  enabled   = true
  readonly  = false
  browsable = true
}

resource "truenas_sharing_smb" "downloads" {
  name      = "downloads"
  path      = "/mnt/primary/root/downloads"
  enabled   = true
  readonly  = false
  browsable = true
}

resource "truenas_sharing_smb" "config" {
  name      = "config"
  path      = "/mnt/primary/root/config"
  enabled   = true
  readonly  = false
  browsable = true
}

resource "truenas_sharing_nfs" "primary_root" {
  path         = "/mnt/primary/root"
  comment      = "primaryroot"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"
}

resource "truenas_sharing_nfs" "audiobooks" {
  path         = "/mnt/primary/root/audiobooks"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"
}

resource "truenas_sharing_nfs" "downloads" {
  path         = "/mnt/primary/root/downloads"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"
}

resource "truenas_sharing_nfs" "config" {
  path         = "/mnt/primary/root/config"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"
}

resource "truenas_sharing_nfs" "storage" {
  path         = "/mnt/primary/root/storage"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_storage]
}

resource "truenas_sharing_nfs" "storage_kestra" {
  path         = "/mnt/primary/root/storage/kestra"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_storage_kestra]
}

resource "truenas_sharing_nfs" "storage_authentik" {
  path         = "/mnt/primary/root/storage/authentik"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_storage_authentik]
}

resource "truenas_sharing_nfs" "usb_ssd_media" {
  path         = "/mnt/usb-ssd/media"
  comment      = "usb-ssd-media"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.usb_ssd_media]
}

resource "truenas_sharing_nfs" "usb_ssd_downloads" {
  path         = "/mnt/usb-ssd/downloads"
  comment      = "usb-ssd-downloads"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.usb_ssd_downloads]
}

resource "truenas_sharing_nfs" "usb_hdd_media" {
  path         = "/mnt/usb-hdd/media"
  comment      = "usb-hdd-media"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.usb_hdd_media]
}

resource "truenas_sharing_nfs" "usb_hdd_downloads" {
  path         = "/mnt/usb-hdd/downloads"
  comment      = "usb-hdd-downloads"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.usb_hdd_downloads]
}
