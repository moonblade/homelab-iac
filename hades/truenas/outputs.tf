output "smb_shares" {
  description = "SMB share paths"
  value = {
    root       = truenas_share_smb.root.path
    audiobooks = truenas_share_smb.audiobooks.path
    downloads  = truenas_share_smb.downloads.path
    config     = truenas_share_smb.config.path
  }
}

output "nfs_shares" {
  description = "NFS share paths"
  value = {
    primary_root = truenas_share_nfs.primary_root.path
    audiobooks   = truenas_share_nfs.audiobooks.path
    downloads    = truenas_share_nfs.downloads.path
    config       = truenas_share_nfs.config.path
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
  }
}
