# Reuse luna tfvars - same Proxmox host, same pm_password
VAR_FILE = -var-file=../../secrets/hades-luna.tfvars

init:
	terraform init

plan:
	terraform plan $(VAR_FILE) -out=sirius.tfplan

apply:
	terraform apply sirius.tfplan

destroy:
	terraform destroy $(VAR_FILE)

# NixOS deployment targets
NIXOS_IP = 192.168.1.150
NIXOS_USER = root

copy:
	scp -r nixos/* $(NIXOS_USER)@$(NIXOS_IP):/etc/nixos/

rebuild:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'nixos-rebuild switch --flake /etc/nixos#sirius'

deploy: copy rebuild
	@echo "NixOS configuration deployed successfully"
