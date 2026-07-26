HOST := root@192.168.1.199
REMOTE_DIR := /root/workspace/nginx-proxy-manager
CONTAINER := nginx-proxy-manager-app-1
SECRETS_DIR := ../../../secrets
DOMAIN := ollama.moonblade.work
OLLAMA_PORT := 11434
NPM_SECRETS := $(SECRETS_DIR)/npm-luna.env
HERMES_UI_DOMAIN := hermes-ui.moonblade.work
HERMES_DASHBOARD_DOMAIN := hermes-dashboard.moonblade.work
HERMES_PORT := 9119

.PHONY: setup deploy copy up down logs status restart wait-ready \
        install-certbot change-password generate-cert configure-proxy renew-cert \
        configure-hermes generate-cert-hermes-ui generate-cert-hermes-dashboard

# Full automated setup: deploy + SSL + proxy host
setup: deploy wait-ready change-password generate-cert configure-proxy
	@echo ""
	@echo "Setup complete!"
	@echo "  Ollama: https://$(DOMAIN)"
	@echo "  NPM Admin: http://$(HOST):81"

# Deploy container and install certbot
deploy: copy up install-certbot
	@echo "NPM deployed on $(HOST)"

# Copy compose file to remote
copy:
	@echo "Copying files to $(HOST):$(REMOTE_DIR)..."
	@ssh $(HOST) "mkdir -p $(REMOTE_DIR)"
	@scp docker-compose.yml $(HOST):$(REMOTE_DIR)/

# Start services
up:
	@echo "Starting Nginx Proxy Manager on $(HOST)..."
	@ssh $(HOST) "cd $(REMOTE_DIR) && docker compose up -d"

# Wait for NPM API to be ready
wait-ready:
	@echo "Waiting for NPM to be ready..."
	@sleep 15
	@for i in 1 2 3 4 5; do \
		if ssh $(HOST) "curl -sf http://127.0.0.1:81/api/ >/dev/null 2>&1"; then \
			echo "NPM is ready"; \
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

# Install certbot-dns-cloudflare plugin inside the NPM container
# Must be re-run after container recreates (not baked into image)
install-certbot:
	@echo "Installing certbot-dns-cloudflare..."
	@ssh $(HOST) "docker exec $(CONTAINER) pip install certbot-dns-cloudflare -q 2>/dev/null || true"

# Change default NPM admin credentials
change-password:
	@echo "Changing NPM admin password..."
	@NPM_EMAIL=$$(grep NPM_EMAIL $(NPM_SECRETS) | cut -d'=' -f2); \
	NPM_PASSWORD=$$(grep NPM_PASSWORD $(NPM_SECRETS) | cut -d'=' -f2); \
	TOKEN=$$(ssh $(HOST) "curl -s -X POST 'http://127.0.0.1:81/api/tokens' \
		-H 'Content-Type: application/json' \
		-d '{\"identity\":\"admin@admin.com\",\"secret\":\"changeme\"}'" \
		| grep -o '"token":"[^"]*"' | cut -d'"' -f4); \
	if [ -n "$$TOKEN" ]; then \
		ssh $(HOST) "curl -s -X PUT 'http://127.0.0.1:81/api/users/1' \
			-H 'Authorization: Bearer $$TOKEN' \
			-H 'Content-Type: application/json' \
			-d '{\"name\":\"Administrator\",\"nickname\":\"Admin\",\"email\":\"$$NPM_EMAIL\"}'" >/dev/null; \
		ssh $(HOST) "curl -s -X PUT 'http://127.0.0.1:81/api/users/1/auth' \
			-H 'Authorization: Bearer $$TOKEN' \
			-H 'Content-Type: application/json' \
			-d '{\"type\":\"password\",\"current\":\"changeme\",\"secret\":\"$$NPM_PASSWORD\"}'" >/dev/null; \
		echo "Password changed"; \
	else \
		echo "  Password already changed or NPM not ready"; \
	fi

# Generate Let's Encrypt wildcard-capable cert via Cloudflare DNS challenge
generate-cert:
	@echo "Generating SSL certificate for $(DOMAIN)..."
	@CF_TOKEN=$$(grep CLOUDFLARE_API_TOKEN $(SECRETS_DIR)/cloudflare.env | cut -d'=' -f2); \
	ssh $(HOST) "docker exec $(CONTAINER) mkdir -p /etc/letsencrypt"; \
	ssh $(HOST) "docker exec $(CONTAINER) sh -c 'echo \"dns_cloudflare_api_token = $$CF_TOKEN\" > /etc/letsencrypt/cloudflare.ini && chmod 600 /etc/letsencrypt/cloudflare.ini'"; \
	ssh $(HOST) "docker exec $(CONTAINER) certbot certonly \
		--dns-cloudflare \
		--dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
		--dns-cloudflare-propagation-seconds 30 \
		-d $(DOMAIN) \
		--non-interactive \
		--agree-tos \
		--email admin@moonblade.work \
		--keep-until-expiring" 2>/dev/null || true
	@echo "Certificate ready"

# Wire certificate + proxy host into NPM via its API
configure-proxy:
	@echo "Configuring proxy host $(DOMAIN) -> localhost:$(OLLAMA_PORT)..."
	@NPM_EMAIL=$$(grep NPM_EMAIL $(NPM_SECRETS) | cut -d'=' -f2); \
	NPM_PASSWORD=$$(grep NPM_PASSWORD $(NPM_SECRETS) | cut -d'=' -f2); \
	TOKEN=$$(ssh $(HOST) "curl -s -X POST 'http://127.0.0.1:81/api/tokens' \
		-H 'Content-Type: application/json' \
		-d '{\"identity\":\"$$NPM_EMAIL\",\"secret\":\"$$NPM_PASSWORD\"}'" \
		| grep -o '"token":"[^"]*"' | cut -d'"' -f4); \
	if [ -z "$$TOKEN" ]; then echo "Failed to get NPM API token"; exit 1; fi; \
	\
	echo "  Registering certificate in NPM database..."; \
	ssh $(HOST) "mkdir -p $(REMOTE_DIR)/letsencrypt/live/npm-1"; \
	ssh $(HOST) "docker cp $(CONTAINER):/etc/letsencrypt/live/$(DOMAIN)/. $(REMOTE_DIR)/letsencrypt/live/npm-1/ 2>/dev/null || \
		cp /etc/letsencrypt/live/$(DOMAIN)/* $(REMOTE_DIR)/letsencrypt/live/npm-1/ 2>/dev/null || true"; \
	ssh $(HOST) "sqlite3 $(REMOTE_DIR)/data/database.sqlite \
		\"INSERT OR REPLACE INTO certificate \
		(id, created_on, modified_on, owner_user_id, provider, nice_name, domain_names, expires_on, meta) \
		VALUES (1, datetime('now'), datetime('now'), 1, 'letsencrypt', '$(DOMAIN)', \
		'[\\\"$(DOMAIN)\\\"]', datetime('now', '+90 days'), '{}')\""; \
	\
	echo "  Creating proxy host..."; \
	EXISTING=$$(ssh $(HOST) "curl -s 'http://127.0.0.1:81/api/nginx/proxy-hosts' \
		-H 'Authorization: Bearer $$TOKEN'" | python3 -c 'import sys,json; h=json.load(sys.stdin); print(len([x for x in h if "$(DOMAIN)" in x.get("domain_names",[])]))'  2>/dev/null || echo 0); \
	if [ "$$EXISTING" = "0" ]; then \
		ssh $(HOST) "curl -s -X POST 'http://127.0.0.1:81/api/nginx/proxy-hosts' \
			-H 'Authorization: Bearer $$TOKEN' \
			-H 'Content-Type: application/json' \
			-d '{ \
				\"domain_names\": [\"$(DOMAIN)\"], \
				\"forward_scheme\": \"http\", \
				\"forward_host\": \"127.0.0.1\", \
				\"forward_port\": $(OLLAMA_PORT), \
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
		echo "Proxy host created: https://$(DOMAIN) -> localhost:$(OLLAMA_PORT)"; \
	else \
		echo "  Proxy host already exists"; \
	fi

# Generate cert for hermes-ui.moonblade.work
generate-cert-hermes-ui:
	@echo "Generating SSL certificate for $(HERMES_UI_DOMAIN)..."
	@CF_TOKEN=$$(grep CLOUDFLARE_API_TOKEN $(SECRETS_DIR)/cloudflare.env | cut -d'=' -f2); \
	ssh $(HOST) "docker exec $(CONTAINER) certbot certonly \
		--dns-cloudflare \
		--dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
		--dns-cloudflare-propagation-seconds 30 \
		-d $(HERMES_UI_DOMAIN) \
		--non-interactive \
		--agree-tos \
		--email admin@moonblade.work \
		--keep-until-expiring" 2>/dev/null || true
	@echo "Certificate ready"

# Generate cert for hermes-dashboard.moonblade.work
generate-cert-hermes-dashboard:
	@echo "Generating SSL certificate for $(HERMES_DASHBOARD_DOMAIN)..."
	@CF_TOKEN=$$(grep CLOUDFLARE_API_TOKEN $(SECRETS_DIR)/cloudflare.env | cut -d'=' -f2); \
	ssh $(HOST) "docker exec $(CONTAINER) certbot certonly \
		--dns-cloudflare \
		--dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
		--dns-cloudflare-propagation-seconds 30 \
		-d $(HERMES_DASHBOARD_DOMAIN) \
		--non-interactive \
		--agree-tos \
		--email admin@moonblade.work \
		--keep-until-expiring" 2>/dev/null || true
	@echo "Certificate ready"

# Configure NPM proxy hosts for hermes-ui and hermes-dashboard → localhost:9119
configure-hermes: generate-cert-hermes-ui generate-cert-hermes-dashboard
	@echo "Configuring proxy hosts for Hermes (port $(HERMES_PORT))..."
	@NPM_EMAIL=$$(grep NPM_EMAIL $(NPM_SECRETS) | cut -d'=' -f2); \
	NPM_PASSWORD=$$(grep NPM_PASSWORD $(NPM_SECRETS) | cut -d'=' -f2); \
	TOKEN=$$(ssh $(HOST) "curl -s -X POST 'http://127.0.0.1:81/api/tokens' \
		-H 'Content-Type: application/json' \
		-d '{\"identity\":\"$$NPM_EMAIL\",\"secret\":\"$$NPM_PASSWORD\"}'" \
		| grep -o '"token":"[^"]*"' | cut -d'"' -f4); \
	if [ -z "$$TOKEN" ]; then echo "Failed to get NPM API token"; exit 1; fi; \
	\
	CERT_ID_UI=$$(ssh $(HOST) "sqlite3 $(REMOTE_DIR)/data/database.sqlite \
		\"SELECT id FROM certificate WHERE nice_name='$(HERMES_UI_DOMAIN)' LIMIT 1\"" 2>/dev/null || echo ""); \
	if [ -z "$$CERT_ID_UI" ]; then \
		ssh $(HOST) "sqlite3 $(REMOTE_DIR)/data/database.sqlite \
			\"INSERT INTO certificate \
			(created_on, modified_on, owner_user_id, provider, nice_name, domain_names, expires_on, meta) \
			VALUES (datetime('now'), datetime('now'), 1, 'letsencrypt', '$(HERMES_UI_DOMAIN)', \
			'[\\\"$(HERMES_UI_DOMAIN)\\\"]', datetime('now', '+90 days'), '{}')\""; \
		CERT_ID_UI=$$(ssh $(HOST) "sqlite3 $(REMOTE_DIR)/data/database.sqlite \
			\"SELECT id FROM certificate WHERE nice_name='$(HERMES_UI_DOMAIN)' ORDER BY id DESC LIMIT 1\""); \
		ssh $(HOST) "mkdir -p $(REMOTE_DIR)/letsencrypt/live/npm-$$CERT_ID_UI"; \
		ssh $(HOST) "docker cp $(CONTAINER):/etc/letsencrypt/live/$(HERMES_UI_DOMAIN)/. \
			$(REMOTE_DIR)/letsencrypt/live/npm-$$CERT_ID_UI/ 2>/dev/null || true"; \
	fi; \
	\
	EXISTING_UI=$$(ssh $(HOST) "curl -s 'http://127.0.0.1:81/api/nginx/proxy-hosts' \
		-H 'Authorization: Bearer $$TOKEN'" | python3 -c 'import sys,json; h=json.load(sys.stdin); print(len([x for x in h if "$(HERMES_UI_DOMAIN)" in x.get("domain_names",[])]))'  2>/dev/null || echo 0); \
	if [ "$$EXISTING_UI" = "0" ]; then \
		ssh $(HOST) "curl -s -X POST 'http://127.0.0.1:81/api/nginx/proxy-hosts' \
			-H 'Authorization: Bearer $$TOKEN' \
			-H 'Content-Type: application/json' \
			-d '{ \
				\"domain_names\": [\"$(HERMES_UI_DOMAIN)\"], \
				\"forward_scheme\": \"http\", \
				\"forward_host\": \"127.0.0.1\", \
				\"forward_port\": $(HERMES_PORT), \
				\"certificate_id\": '$$CERT_ID_UI', \
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
		echo "Proxy host created: https://$(HERMES_UI_DOMAIN) -> localhost:$(HERMES_PORT)"; \
	else \
		echo "  Proxy host $(HERMES_UI_DOMAIN) already exists"; \
	fi; \
	\
	CERT_ID_DASH=$$(ssh $(HOST) "sqlite3 $(REMOTE_DIR)/data/database.sqlite \
		\"SELECT id FROM certificate WHERE nice_name='$(HERMES_DASHBOARD_DOMAIN)' LIMIT 1\"" 2>/dev/null || echo ""); \
	if [ -z "$$CERT_ID_DASH" ]; then \
		ssh $(HOST) "sqlite3 $(REMOTE_DIR)/data/database.sqlite \
			\"INSERT INTO certificate \
			(created_on, modified_on, owner_user_id, provider, nice_name, domain_names, expires_on, meta) \
			VALUES (datetime('now'), datetime('now'), 1, 'letsencrypt', '$(HERMES_DASHBOARD_DOMAIN)', \
			'[\\\"$(HERMES_DASHBOARD_DOMAIN)\\\"]', datetime('now', '+90 days'), '{}')\""; \
		CERT_ID_DASH=$$(ssh $(HOST) "sqlite3 $(REMOTE_DIR)/data/database.sqlite \
			\"SELECT id FROM certificate WHERE nice_name='$(HERMES_DASHBOARD_DOMAIN)' ORDER BY id DESC LIMIT 1\""); \
		ssh $(HOST) "mkdir -p $(REMOTE_DIR)/letsencrypt/live/npm-$$CERT_ID_DASH"; \
		ssh $(HOST) "docker cp $(CONTAINER):/etc/letsencrypt/live/$(HERMES_DASHBOARD_DOMAIN)/. \
			$(REMOTE_DIR)/letsencrypt/live/npm-$$CERT_ID_DASH/ 2>/dev/null || true"; \
	fi; \
	\
	EXISTING_DASH=$$(ssh $(HOST) "curl -s 'http://127.0.0.1:81/api/nginx/proxy-hosts' \
		-H 'Authorization: Bearer $$TOKEN'" | python3 -c 'import sys,json; h=json.load(sys.stdin); print(len([x for x in h if "$(HERMES_DASHBOARD_DOMAIN)" in x.get("domain_names",[])]))'  2>/dev/null || echo 0); \
	if [ "$$EXISTING_DASH" = "0" ]; then \
		ssh $(HOST) "curl -s -X POST 'http://127.0.0.1:81/api/nginx/proxy-hosts' \
			-H 'Authorization: Bearer $$TOKEN' \
			-H 'Content-Type: application/json' \
			-d '{ \
				\"domain_names\": [\"$(HERMES_DASHBOARD_DOMAIN)\"], \
				\"forward_scheme\": \"http\", \
				\"forward_host\": \"127.0.0.1\", \
				\"forward_port\": $(HERMES_PORT), \
				\"certificate_id\": '$$CERT_ID_DASH', \
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
		echo "Proxy host created: https://$(HERMES_DASHBOARD_DOMAIN) -> localhost:$(HERMES_PORT)"; \
	else \
		echo "  Proxy host $(HERMES_DASHBOARD_DOMAIN) already exists"; \
	fi

# Renew certificate manually (fallback; normally auto-renewed by certbot inside container)
# Re-installs certbot-dns-cloudflare each time — not baked into NPM image, lost on container recreate
renew-cert:
	@echo "Installing certbot-dns-cloudflare plugin..."
	@ssh $(HOST) "docker exec $(CONTAINER) pip install certbot-dns-cloudflare -q"
	@echo "Renewing certificate..."
	@CF_TOKEN=$$(grep CLOUDFLARE_API_TOKEN $(SECRETS_DIR)/cloudflare.env | cut -d'=' -f2); \
	ssh $(HOST) "docker exec $(CONTAINER) sh -c 'echo \"dns_cloudflare_api_token = $$CF_TOKEN\" > /etc/letsencrypt/cloudflare.ini && chmod 600 /etc/letsencrypt/cloudflare.ini'"; \
	ssh $(HOST) "docker exec $(CONTAINER) certbot certonly \
		--dns-cloudflare \
		--dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
		--dns-cloudflare-propagation-seconds 30 \
		-d $(DOMAIN) \
		--non-interactive \
		--agree-tos \
		--email admin@moonblade.work \
		--force-renewal 2>&1"
	@echo "Copying renewed cert into NPM letsencrypt volume..."
	@ssh $(HOST) "docker cp $(CONTAINER):/etc/letsencrypt/archive/$(DOMAIN)/fullchain2.pem \
		$(REMOTE_DIR)/letsencrypt/live/npm-1/fullchain.pem 2>/dev/null || \
		docker cp $(CONTAINER):/etc/letsencrypt/archive/$(DOMAIN)/fullchain1.pem \
		$(REMOTE_DIR)/letsencrypt/live/npm-1/fullchain.pem"
	@ssh $(HOST) "docker cp $(CONTAINER):/etc/letsencrypt/archive/$(DOMAIN)/privkey2.pem \
		$(REMOTE_DIR)/letsencrypt/live/npm-1/privkey.pem 2>/dev/null || \
		docker cp $(CONTAINER):/etc/letsencrypt/archive/$(DOMAIN)/privkey1.pem \
		$(REMOTE_DIR)/letsencrypt/live/npm-1/privkey.pem"
	@ssh $(HOST) "docker cp $(CONTAINER):/etc/letsencrypt/archive/$(DOMAIN)/cert2.pem \
		$(REMOTE_DIR)/letsencrypt/live/npm-1/cert.pem 2>/dev/null || \
		docker cp $(CONTAINER):/etc/letsencrypt/archive/$(DOMAIN)/cert1.pem \
		$(REMOTE_DIR)/letsencrypt/live/npm-1/cert.pem"
	@ssh $(HOST) "docker exec $(CONTAINER) nginx -s reload"
	@echo "Certificate renewed and NPM reloaded"
