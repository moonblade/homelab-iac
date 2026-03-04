VAR_FILE = -var-file=../../secrets/hades-luna.tfvars

init:
	terraform init

plan:
	terraform plan $(VAR_FILE) -out=hades-desktop.tfplan

apply:
	terraform apply hades-desktop.tfplan

destroy:
	terraform destroy $(VAR_FILE)

# NixOS deployment targets
NIXOS_IP = 192.168.1.199
NIXOS_USER = root

copy:
	scp -r nixos/* $(NIXOS_USER)@$(NIXOS_IP):/etc/nixos/luna/

rebuild:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'nixos-rebuild switch --flake /etc/nixos/luna#luna'

deploy: copy rebuild
	@echo "NixOS configuration deployed successfully"

# Tailscale setup (run after first boot)
tailscale:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'tailscale up'
