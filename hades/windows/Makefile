SECRETS_FILE = ../../secrets/hades-windows.tfvars

init:
	terraform init

plan:
	terraform plan -var-file=$(SECRETS_FILE) -out=hades-windows.tfplan

apply:
	terraform apply hades-windows.tfplan

destroy:
	terraform destroy -var-file=$(SECRETS_FILE)
