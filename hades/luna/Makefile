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
	@echo "Copying kubeconfig (sirius)..."
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'mkdir -p /home/moonblade/.kube'
	@scp $(SECRETS_DIR)/sirius.yaml $(NIXOS_USER)@$(NIXOS_IP):/home/moonblade/.kube/sirius.yaml
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'chown moonblade:users /home/moonblade/.kube/sirius.yaml && chmod 600 /home/moonblade/.kube/sirius.yaml'
	@echo "Copying beszel secrets..."
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'mkdir -p /var/lib/beszel-agent'
	@grep '^BESZEL_KEY=' $(SECRETS_DIR)/beszel.env | sed 's/BESZEL_KEY=/KEY=/' | ssh $(NIXOS_USER)@$(NIXOS_IP) 'cat > /var/lib/beszel-agent/beszel.env'
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'chmod 600 /var/lib/beszel-agent/beszel.env'
	@echo "Copying NPM secrets..."
	@scp $(SECRETS_DIR)/npm-luna.env $(NIXOS_USER)@$(NIXOS_IP):/root/workspace/npm-luna.env
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'chmod 600 /root/workspace/npm-luna.env'
	@echo "Copying hermes secrets..."
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'mkdir -p /run/secrets'
	@scp $(SECRETS_DIR)/hermes-luna.env $(NIXOS_USER)@$(NIXOS_IP):/run/secrets/hermes-luna.env
	@ssh $(NIXOS_USER)@$(NIXOS_IP) 'chmod 600 /run/secrets/hermes-luna.env'

# Set up NPM + SSL + proxy host for ollama.moonblade.work
npm-setup:
	@$(MAKE) -C nginx-proxy-manager setup

rebuild:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'nixos-rebuild switch --flake /etc/nixos/luna#luna'

deploy: copy copy-secrets rebuild
	@echo "NixOS configuration deployed successfully"

# Tailscale setup (run after first boot)
tailscale:
	ssh $(NIXOS_USER)@$(NIXOS_IP) 'tailscale up'
