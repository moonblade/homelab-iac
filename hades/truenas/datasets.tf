resource "truenas_pool_dataset" "apps_filebrowser" {
  name        = "apps/filebrowser"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "DISCARD"
  acltype     = "POSIX"
}

resource "truenas_pool_dataset" "primary_root" {
  name        = "primary/root"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"
}

resource "truenas_pool_dataset" "primary_root_audiobooks" {
  name        = "primary/root/audiobooks"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root]
}

resource "truenas_pool_dataset" "primary_root_config" {
  name        = "primary/root/config"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root]
}

resource "truenas_pool_dataset" "primary_root_downloads" {
  name        = "primary/root/downloads"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root]
}

# Storage dataset for local-path provisioner (general K8s PVCs)
resource "truenas_pool_dataset" "primary_root_storage" {
  name        = "primary/root/storage"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root]
}

# Authentik data (nested under storage for organization, but backed up separately)
resource "truenas_pool_dataset" "primary_root_storage_authentik" {
  name        = "primary/root/storage/authentik"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root_storage]
}

# Kestra data (nested under storage, similar to authentik)
resource "truenas_pool_dataset" "primary_root_storage_kestra" {
  name        = "primary/root/storage/kestra"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root_storage]
}

# Backup dataset on secondary pool for kestra replication
resource "truenas_pool_dataset" "secondary_kestra_backup" {
  name        = "secondary/kestra-backup"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"
}

# Backup dataset on secondary pool for config replication
resource "truenas_pool_dataset" "secondary_config_backup" {
  name        = "secondary/config-backup"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"
}

# Backup dataset on secondary pool for authentik replication
resource "truenas_pool_dataset" "secondary_authentik_backup" {
  name        = "secondary/authentik-backup"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"
}

# USB SSD datasets (media/downloads - fast scratch storage)
resource "truenas_pool_dataset" "usb_ssd_media" {
  name        = "usb-ssd/media"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"
}

resource "truenas_pool_dataset" "usb_ssd_downloads" {
  name        = "usb-ssd/downloads"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"
}

# USB HDD datasets (media/downloads - bulk storage)
resource "truenas_pool_dataset" "usb_hdd_media" {
  name        = "usb-hdd/media"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"
}

resource "truenas_pool_dataset" "usb_hdd_downloads" {
  name        = "usb-hdd/downloads"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"
}
