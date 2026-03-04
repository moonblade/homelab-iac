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

resource "truenas_sharing_nfs" "storage_authentik" {
  path         = "/mnt/primary/root/storage/authentik"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_storage_authentik]
}
