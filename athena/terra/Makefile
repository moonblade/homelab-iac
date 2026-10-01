VAR_FILE = -var-file=../../secrets/athena-terra.tfvars

init:
	terraform init

plan:
	terraform plan $(VAR_FILE) -out=athena-terra.tfplan

apply:
	terraform apply athena-terra.tfplan

destroy:
	terraform destroy $(VAR_FILE)

# NixOS deployment targets
NIXOS_IP = 192.168.1.200
NIXOS_USER = root

copy:
	scp -r nixos/* $(NIXOS_USER)@$(NIXOS_IP):/etc/nixos/terra/

copy-secrets:
	@echo "Copying beszel secrets..."
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'mkdir -p /var/lib/beszel-agent'
	@grep '^BESZEL_KEY=' ../../secrets/beszel.env | sed 's/BESZEL_KEY=/KEY=/' | ssh $(NIXOS_USER)@$(NIXOS_IP) 'cat > /var/lib/beszel-agent/beszel.env'
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'chmod 600 /var/lib/beszel-agent/beszel.env'

rebuild:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'nixos-rebuild switch --flake /etc/nixos/terra#terra'

deploy: copy copy-secrets rebuild
	@echo "NixOS configuration deployed successfully"

# Tailscale setup (run after first boot)
tailscale:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'tailscale up'
