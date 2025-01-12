init:
	terraform init

plan:
	terraform plan -out=athena.tfplan

apply:
	terraform apply athena.tfplan

destroy:
	terraform destroy

add-lvm:
	qm set 301 --virtio2 /dev/external/external-thinvol
