HOST := hadests
REMOTE_DIR := /root/workspace/nginx-proxy-manager
CONTAINER := nginx-proxy-manager-app-1
SECRETS_DIR := ../../secrets
DOMAIN := hades.moonblade.work

.PHONY: setup deploy up down logs status restart install-certbot generate-cert configure-npm renew-cert

# Full automated setup: deploy + SSL + proxy host
setup: deploy wait-ready change-password generate-cert configure-proxy
	@echo ""
	@echo "✓ Setup complete!"
	@echo "  Proxmox: https://$(DOMAIN)"
	@echo "  NPM Admin: http://$(DOMAIN):81"

# Deploy container and install certbot
deploy: copy up install-certbot
	@echo "✓ NPM deployed"

# Copy files to remote
copy:
	@echo "Copying files to $(HOST):$(REMOTE_DIR)..."
	@ssh $(HOST) "mkdir -p $(REMOTE_DIR)"
	@scp docker-compose.yml $(HOST):$(REMOTE_DIR)/

# Start services
up:
	@echo "Starting Nginx Proxy Manager..."
	@ssh $(HOST) "cd $(REMOTE_DIR) && docker compose up -d"

# Wait for NPM to be ready
wait-ready:
	@echo "Waiting for NPM to be ready..."
	@sleep 15
	@for i in 1 2 3 4 5; do \
		if ssh $(HOST) "curl -sf http://127.0.0.1:81/api/ >/dev/null 2>&1"; then \
			echo "✓ NPM is ready"; \
			break; \
		fi; \
		echo "  Waiting... ($$i/5)"; \
		sleep 5; \
	done

# Stop services
down:
	@ssh $(HOST) "cd $(REMOTE_DIR) && docker compose down"

# View logs
logs:
	@ssh $(HOST) "docker logs $(CONTAINER) --tail 50 -f"

# Check status
status:
	@ssh $(HOST) "docker ps | grep nginx-proxy-manager || echo 'Container not running'"
	@echo ""
	@echo "Testing HTTPS..."
	@curl -sk -o /dev/null -w 'HTTP Status: %{http_code}\n' https://$(DOMAIN) 2>/dev/null || echo "HTTPS not configured yet"

# Restart container
restart:
	@ssh $(HOST) "docker restart $(CONTAINER)"

# Install certbot-dns-cloudflare plugin
install-certbot:
	@echo "Installing certbot-dns-cloudflare..."
	@ssh $(HOST) "docker exec $(CONTAINER) pip install certbot-dns-cloudflare 2>/dev/null || true"

# Change default password
change-password:
	@echo "Changing NPM admin password..."
	@NPM_EMAIL=$$(grep NPM_EMAIL $(SECRETS_DIR)/npm-hades.env | cut -d'=' -f2); \
	NPM_PASSWORD=$$(grep NPM_PASSWORD $(SECRETS_DIR)/npm-hades.env | cut -d'=' -f2); \
	TOKEN=$$(ssh $(HOST) "curl -s -X POST 'http://127.0.0.1:81/api/tokens' -H 'Content-Type: application/json' -d '{\"identity\":\"admin@admin.com\",\"secret\":\"changeme\"}'" | grep -o '"token":"[^"]*"' | cut -d'"' -f4); \
	if [ -n "$$TOKEN" ]; then \
		ssh $(HOST) "curl -s -X PUT 'http://127.0.0.1:81/api/users/1' -H 'Authorization: Bearer $$TOKEN' -H 'Content-Type: application/json' -d '{\"name\":\"Administrator\",\"nickname\":\"Admin\",\"email\":\"$$NPM_EMAIL\"}'" >/dev/null; \
		ssh $(HOST) "curl -s -X PUT 'http://127.0.0.1:81/api/users/1/auth' -H 'Authorization: Bearer $$TOKEN' -H 'Content-Type: application/json' -d '{\"type\":\"password\",\"current\":\"changeme\",\"secret\":\"$$NPM_PASSWORD\"}'" >/dev/null; \
		echo "✓ Password changed"; \
	else \
		echo "  Password already changed or NPM not ready"; \
	fi

# Generate Let's Encrypt certificate
generate-cert:
	@echo "Generating SSL certificate..."
	@CF_TOKEN=$$(grep CLOUDFLARE_API_TOKEN $(SECRETS_DIR)/cloudflare.env | cut -d'=' -f2); \
	ssh $(HOST) "docker exec $(CONTAINER) mkdir -p /etc/letsencrypt"; \
	ssh $(HOST) "docker exec $(CONTAINER) sh -c 'echo \"dns_cloudflare_api_token = $$CF_TOKEN\" > /etc/letsencrypt/cloudflare.ini'"; \
	ssh $(HOST) "docker exec $(CONTAINER) chmod 600 /etc/letsencrypt/cloudflare.ini"; \
	ssh $(HOST) "docker exec $(CONTAINER) certbot certonly \
		--dns-cloudflare \
		--dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
		-d $(DOMAIN) \
		--non-interactive \
		--agree-tos \
		--email admin@moonblade.work \
		--keep-until-expiring" 2>/dev/null || true
	@echo "✓ Certificate ready"

# Configure proxy host via API
configure-proxy:
	@echo "Configuring proxy host..."
	@NPM_EMAIL=$$(grep NPM_EMAIL $(SECRETS_DIR)/npm-hades.env | cut -d'=' -f2); \
	NPM_PASSWORD=$$(grep NPM_PASSWORD $(SECRETS_DIR)/npm-hades.env | cut -d'=' -f2); \
	TOKEN=$$(ssh $(HOST) "curl -s -X POST 'http://127.0.0.1:81/api/tokens' -H 'Content-Type: application/json' -d '{\"identity\":\"$$NPM_EMAIL\",\"secret\":\"$$NPM_PASSWORD\"}'" | grep -o '"token":"[^"]*"' | cut -d'"' -f4); \
	if [ -z "$$TOKEN" ]; then echo "Failed to get API token"; exit 1; fi; \
	\
	echo "  Setting up certificate in NPM..."; \
	ssh $(HOST) "mkdir -p $(REMOTE_DIR)/letsencrypt/live/npm-1"; \
	ssh $(HOST) "cp /etc/letsencrypt/live/$(DOMAIN)/* $(REMOTE_DIR)/letsencrypt/live/npm-1/ 2>/dev/null || \
		docker cp $(CONTAINER):/etc/letsencrypt/live/$(DOMAIN)/. $(REMOTE_DIR)/letsencrypt/live/npm-1/"; \
	ssh $(HOST) "sqlite3 $(REMOTE_DIR)/data/database.sqlite \"INSERT OR REPLACE INTO certificate (id, created_on, modified_on, owner_user_id, provider, nice_name, domain_names, expires_on, meta) VALUES (1, datetime('now'), datetime('now'), 1, 'letsencrypt', '$(DOMAIN)', '[\\\"$(DOMAIN)\\\"]', datetime('now', '+90 days'), '{}')\""; \
	\
	echo "  Creating proxy host..."; \
	EXISTING=$$(ssh $(HOST) "curl -s 'http://127.0.0.1:81/api/nginx/proxy-hosts' -H 'Authorization: Bearer $$TOKEN'" | grep -c '"id":1' || echo 0); \
	if [ "$$EXISTING" = "0" ]; then \
		ssh $(HOST) "curl -s -X POST 'http://127.0.0.1:81/api/nginx/proxy-hosts' -H 'Authorization: Bearer $$TOKEN' -H 'Content-Type: application/json' -d '{ \
			\"domain_names\": [\"$(DOMAIN)\"], \
			\"forward_scheme\": \"https\", \
			\"forward_host\": \"127.0.0.1\", \
			\"forward_port\": 8006, \
			\"certificate_id\": 1, \
			\"ssl_forced\": true, \
			\"http2_support\": true, \
			\"allow_websocket_upgrade\": true, \
			\"block_exploits\": false, \
			\"access_list_id\": 0, \
			\"advanced_config\": \"\", \
			\"enabled\": 1, \
			\"meta\": {}, \
			\"locations\": [] \
		}'" >/dev/null; \
		echo "✓ Proxy host created"; \
	else \
		echo "  Proxy host already exists"; \
	fi

# Renew certificate
renew-cert:
	@ssh $(HOST) "docker exec $(CONTAINER) certbot renew"
	@echo "✓ Certificate renewed"
