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

resource "truenas_sharing_smb" "videos" {
  name      = "videos"
  path      = "/mnt/primary/root/videos"
  enabled   = true
  readonly  = false
  browsable = true
}

resource "truenas_sharing_nfs" "primary_root" {
  path         = "/mnt/primary/root"
  comment      = "primaryroot"
  enabled      = true
  ro           = false
  mapall_user  = "moonblade"
  mapall_group = "moonblade"
}

resource "truenas_sharing_nfs" "audiobooks" {
  path         = "/mnt/primary/root/audiobooks"
  enabled      = true
  ro           = false
  mapall_user  = "moonblade"
  mapall_group = "moonblade"
}

resource "truenas_sharing_nfs" "downloads" {
  path         = "/mnt/primary/root/downloads"
  enabled      = true
  ro           = false
  mapall_user  = "moonblade"
  mapall_group = "moonblade"
}

resource "truenas_sharing_nfs" "config" {
  path         = "/mnt/primary/root/config"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"
}

# basic-memory NFS share: mapall to moonblade so all machines can read/write without root
resource "truenas_sharing_nfs" "basic_memory" {
  path         = "/mnt/primary/root/basic-memory"
  enabled      = true
  ro           = false
  mapall_user  = "moonblade"
  mapall_group = "moonblade"

  depends_on = [truenas_pool_dataset.primary_root_basic_memory]
}

resource "truenas_sharing_nfs" "videos" {
  path         = "/mnt/primary/root/videos"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_videos]
}

resource "truenas_sharing_nfs" "config_home_assistant" {
  path         = "/mnt/primary/root/config/home-assistant"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_config_home_assistant]
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

resource "truenas_sharing_nfs" "storage_ollama" {
  path         = "/mnt/primary/root/storage/ollama"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_storage_ollama]
}

resource "truenas_sharing_nfs" "storage_seafile" {
  path         = "/mnt/primary/root/storage/seafile"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_storage_seafile]
}

resource "truenas_sharing_nfs" "storage_immich" {
  path         = "/mnt/primary/root/storage/immich"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_storage_immich]
}

# Games NFS share: mapall to moonblade (uid=1000) so Steam on Luna can write
# game manifests, compatdata, and shadercache without root ownership issues.
resource "truenas_sharing_nfs" "storage_games" {
  path         = "/mnt/primary/root/storage/games"
  enabled      = true
  ro           = false
  mapall_user  = "moonblade"
  mapall_group = "moonblade"

  depends_on = [
    truenas_pool_dataset.primary_root_storage_games,
    truenas_user.moonblade,
  ]
}

resource "truenas_sharing_nfs" "storage_firefly" {
  path         = "/mnt/primary/root/storage/firefly"
  enabled      = true
  ro           = false
  mapall_user  = "root"
  mapall_group = "root"

  depends_on = [truenas_pool_dataset.primary_root_storage_firefly]
}

# USB pool shares (usb-ssd, usb-hdd) removed — pools no longer connected.
# Reinstate if USB pools are reattached.

# downloads/orion subdir — plain directory NFS share for Orion downloads
resource "truenas_sharing_nfs" "downloads_orion" {
  path         = "/mnt/primary/root/downloads/orion"
  comment      = "orion"
  enabled      = true
  ro           = false
  mapall_user  = "moonblade"
  mapall_group = "moonblade"
}

# relay — cross-machine file drop/sync directory
resource "truenas_sharing_nfs" "relay" {
  path         = "/mnt/primary/root/relay"
  comment      = "relay - cross-machine downloads sync"
  enabled      = true
  ro           = false
  mapall_user  = "moonblade"
  mapall_group = "moonblade"
}
