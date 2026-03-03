output "smb_shares" {
  description = "SMB share paths"
  value = {
    root       = truenas_sharing_smb.root.path
    audiobooks = truenas_sharing_smb.audiobooks.path
    downloads  = truenas_sharing_smb.downloads.path
    config     = truenas_sharing_smb.config.path
  }
}

output "nfs_shares" {
  description = "NFS share paths"
  value = {
    primary_root = truenas_sharing_nfs.primary_root.path
    audiobooks   = truenas_sharing_nfs.audiobooks.path
    downloads    = truenas_sharing_nfs.downloads.path
    config       = truenas_sharing_nfs.config.path
  }
}

output "datasets" {
  description = "Dataset paths"
  value = {
    apps_filebrowser        = truenas_pool_dataset.apps_filebrowser.name
    primary_root            = truenas_pool_dataset.primary_root.name
    primary_root_audiobooks = truenas_pool_dataset.primary_root_audiobooks.name
    primary_root_config     = truenas_pool_dataset.primary_root_config.name
    primary_root_downloads  = truenas_pool_dataset.primary_root_downloads.name
    secondary_config_backup = truenas_pool_dataset.secondary_config_backup.name
  }
}

output "backup" {
  description = "Backup configuration"
  value = {
    snapshot_task_id   = truenas_pool_snapshottask.config_daily.id
    replication_id     = truenas_replication.config_to_secondary.id
    source_dataset     = "primary/root/config"
    target_dataset     = "secondary/config-backup"
    snapshot_schedule  = "Daily at 2:00 AM"
    snapshot_retention = "14 days"
    replica_retention  = "30 days"
  }
}
