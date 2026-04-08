HOST := athena
REMOTE_DIR := /root/workspace/beszel-agent
CONTAINER := beszel-agent
SECRETS_DIR := ../../secrets

.PHONY: deploy up down logs status restart copy

deploy: copy up
	@echo "✓ Beszel agent deployed on Athena"

copy:
	@echo "Copying files to $(HOST):$(REMOTE_DIR)..."
	@ssh $(HOST) "mkdir -p $(REMOTE_DIR)"
	@scp docker-compose.yml $(HOST):$(REMOTE_DIR)/

up:
	@echo "Starting Beszel agent..."
	@BESZEL_KEY=$$(grep BESZEL_KEY $(SECRETS_DIR)/beszel.env | cut -d'=' -f2); \
	ssh $(HOST) "cd $(REMOTE_DIR) && BESZEL_KEY='$$BESZEL_KEY' docker compose up -d"

down:
	@ssh $(HOST) "cd $(REMOTE_DIR) && docker compose down"

logs:
	@ssh $(HOST) "docker logs $(CONTAINER) --tail 50 -f"

status:
	@ssh $(HOST) "docker ps | grep beszel-agent || echo 'Container not running'"

restart:
	@ssh $(HOST) "docker restart $(CONTAINER)"
