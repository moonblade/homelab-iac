init:
	terraform init

plan:
	terraform plan -out=truenas.tfplan

apply:
	terraform apply truenas.tfplan

destroy:
	terraform destroy

import-datasets:
	terraform import truenas_pool_dataset.apps_filebrowser "apps/filebrowser"
	terraform import truenas_pool_dataset.primary_root "primary/root"
	terraform import truenas_pool_dataset.primary_root_audiobooks "primary/root/audiobooks"
	terraform import truenas_pool_dataset.primary_root_config "primary/root/config"
	terraform import truenas_pool_dataset.primary_root_downloads "primary/root/downloads"

import-smb:
	terraform import truenas_share_smb.root "1"
	terraform import truenas_share_smb.audiobooks "2"
	terraform import truenas_share_smb.downloads "3"
	terraform import truenas_share_smb.config "4"

import-nfs:
	terraform import truenas_share_nfs.primary_root "2"
	terraform import truenas_share_nfs.audiobooks "3"
	terraform import truenas_share_nfs.downloads "4"
	terraform import truenas_share_nfs.config "5"

import-all: import-datasets import-smb import-nfs
