VAR_FILE = -var-file=../../secrets/hades-ares.tfvars

init:
	terraform init

plan:
	terraform plan $(VAR_FILE) -out=hades-ares.tfplan

apply:
	terraform apply hades-ares.tfplan

destroy:
	terraform destroy $(VAR_FILE)

# NixOS deployment targets
NIXOS_IP = 192.168.1.197
NIXOS_USER = root

copy:
	scp -r nixos/* $(NIXOS_USER)@$(NIXOS_IP):/etc/nixos/ares/

rebuild:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'nixos-rebuild switch --flake /etc/nixos/ares#ares'

deploy: copy rebuild
	@echo "NixOS configuration deployed successfully"

# Tailscale setup (run after first boot)
tailscale:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'tailscale up'
