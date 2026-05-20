VAR_FILE = -var-file=../../secrets/hades-luna.tfvars
SECRETS_DIR = ../../secrets

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

copy-secrets:
	@echo "Copying beszel secrets..."
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'mkdir -p /var/lib/beszel-agent'
	@grep '^BESZEL_KEY=' $(SECRETS_DIR)/beszel.env | sed 's/BESZEL_KEY=/KEY=/' | ssh $(NIXOS_USER)@$(NIXOS_IP) 'cat > /var/lib/beszel-agent/beszel.env'
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'chmod 600 /var/lib/beszel-agent/beszel.env'

rebuild:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'nixos-rebuild switch --flake /etc/nixos/luna#luna'

deploy: copy copy-secrets rebuild
	@echo "NixOS configuration deployed successfully"

# Tailscale setup (run after first boot)
tailscale:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'tailscale up'
