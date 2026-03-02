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
  path    = "/mnt/primary/root"
  comment = "primaryroot"
  enabled = true
  ro      = false
}

resource "truenas_sharing_nfs" "audiobooks" {
  path          = "/mnt/primary/root/audiobooks"
  enabled       = true
  ro            = false
  maproot_user  = "root"
  maproot_group = "root"
}

resource "truenas_sharing_nfs" "downloads" {
  path          = "/mnt/primary/root/downloads"
  enabled       = true
  ro            = false
  maproot_user  = "root"
  maproot_group = "root"
}

resource "truenas_sharing_nfs" "config" {
  path          = "/mnt/primary/root/config"
  enabled       = true
  ro            = false
  maproot_user  = "root"
  maproot_group = "root"
}
