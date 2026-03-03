VAR_FILE = -var-file=../../secrets/truenas.tfvars

init:
	terraform init

plan:
	terraform plan $(VAR_FILE) -out=truenas.tfplan

apply:
	terraform apply truenas.tfplan

destroy:
	terraform destroy $(VAR_FILE)

import-datasets:
	terraform import $(VAR_FILE) truenas_pool_dataset.apps_filebrowser "apps/filebrowser"
	terraform import $(VAR_FILE) truenas_pool_dataset.primary_root "primary/root"
	terraform import $(VAR_FILE) truenas_pool_dataset.primary_root_audiobooks "primary/root/audiobooks"
	terraform import $(VAR_FILE) truenas_pool_dataset.primary_root_config "primary/root/config"
	terraform import $(VAR_FILE) truenas_pool_dataset.primary_root_downloads "primary/root/downloads"

import-smb:
	terraform import $(VAR_FILE) truenas_sharing_smb.root "1"
	terraform import $(VAR_FILE) truenas_sharing_smb.audiobooks "2"
	terraform import $(VAR_FILE) truenas_sharing_smb.downloads "3"
	terraform import $(VAR_FILE) truenas_sharing_smb.config "4"

import-nfs:
	terraform import $(VAR_FILE) truenas_sharing_nfs.primary_root "2"
	terraform import $(VAR_FILE) truenas_sharing_nfs.audiobooks "3"
	terraform import $(VAR_FILE) truenas_sharing_nfs.downloads "4"
	terraform import $(VAR_FILE) truenas_sharing_nfs.config "5"

import-all: import-datasets import-smb import-nfs
