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
