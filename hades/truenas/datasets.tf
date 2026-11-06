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

# Ollama model storage (nested under storage, similar to authentik/kestra)
resource "truenas_pool_dataset" "primary_root_storage_ollama" {
  name        = "primary/root/storage/ollama"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root_storage]
}

# Firefly III data (PostgreSQL + app uploads)
resource "truenas_pool_dataset" "primary_root_storage_firefly" {
  name        = "primary/root/storage/firefly"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root_storage]
}

# Seafile data (MariaDB + app data)
resource "truenas_pool_dataset" "primary_root_storage_seafile" {
  name        = "primary/root/storage/seafile"
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

# Immich data (photos library + PostgreSQL)
resource "truenas_pool_dataset" "primary_root_storage_immich" {
  name        = "primary/root/storage/immich"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root_storage]
}

resource "truenas_pool_dataset" "primary_root_storage_games" {
  name            = "primary/root/storage/games"
  type            = "FILESYSTEM"
  compression     = "LZ4"
  atime           = "OFF"
  aclmode         = "PASSTHROUGH"
  acltype         = "NFSV4"
  casesensitivity = "SENSITIVE"

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [truenas_pool_dataset.primary_root_storage]
}

# Backup dataset on secondary pool for firefly replication
resource "truenas_pool_dataset" "secondary_firefly_backup" {
  name        = "secondary/firefly-backup"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"
}

# Home Assistant config
resource "truenas_pool_dataset" "primary_root_config_home_assistant" {
  name        = "primary/root/config/home-assistant"
  type        = "FILESYSTEM"
  compression = "LZ4"
  atime       = "OFF"
  aclmode     = "PASSTHROUGH"
  acltype     = "NFSV4"

  depends_on = [truenas_pool_dataset.primary_root_config]
}

# USB pools (usb-ssd, usb-hdd) are no longer connected — datasets removed from TF.
# If a USB pool is reconnected, re-add and re-import the datasets.

# basic-memory sync hub (shared across home mac, work mac, luna)
resource "truenas_pool_dataset" "primary_root_basic_memory" {
  name            = "primary/root/basic-memory"
  type            = "FILESYSTEM"
  compression     = "LZ4"
  atime           = "OFF"
  aclmode         = "PASSTHROUGH"
  acltype         = "NFSV4"
  casesensitivity = "SENSITIVE"

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [truenas_pool_dataset.primary_root]
}

# Videos/movies library under primary root
resource "truenas_pool_dataset" "primary_root_videos" {
  name            = "primary/root/videos"
  type            = "FILESYSTEM"
  compression     = "LZ4"
  atime           = "OFF"
  aclmode         = "PASSTHROUGH"
  acltype         = "NFSV4"
  casesensitivity = "SENSITIVE"

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [truenas_pool_dataset.primary_root]
}
