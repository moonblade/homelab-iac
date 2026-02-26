# Hades (Proxmox Server) Infrastructure

.PHONY: nginx-proxy-manager npm-status npm-logs

# Deploy Nginx Proxy Manager with SSL for Proxmox
nginx-proxy-manager:
	@$(MAKE) -C nginx-proxy-manager setup

# Check NPM status
npm-status:
	@$(MAKE) -C nginx-proxy-manager status

# View NPM logs
npm-logs:
	@$(MAKE) -C nginx-proxy-manager logs
