HOST := truenas
PROXY := hadests
TRUENAS_IP := 192.168.1.10
REMOTE_DIR := /root/beszel-agent
SECRETS_DIR := ../../../secrets
VERSION := 0.18.7

.PHONY: deploy up down logs status restart copy download

# TrueNAS has no internet access, so we download binary locally and copy it
deploy: copy download up
	@echo "✓ Beszel agent deployed on TrueNAS"

copy:
	@echo "Copying files to $(TRUENAS_IP):$(REMOTE_DIR) via $(PROXY)..."
	@ssh -J $(PROXY) root@$(TRUENAS_IP) "mkdir -p $(REMOTE_DIR)"

download:
	@echo "Downloading beszel-agent v$(VERSION)..."
	@curl -sL "https://github.com/henrygd/beszel/releases/download/v$(VERSION)/beszel-agent_linux_amd64.tar.gz" -o /tmp/beszel-agent.tar.gz
	@scp -o ProxyJump=$(PROXY) /tmp/beszel-agent.tar.gz root@$(TRUENAS_IP):$(REMOTE_DIR)/
	@ssh -J $(PROXY) root@$(TRUENAS_IP) "cd $(REMOTE_DIR) && tar -xzf beszel-agent.tar.gz && chmod +x beszel-agent"
	@rm /tmp/beszel-agent.tar.gz

up:
	@echo "Starting Beszel agent..."
	@BESZEL_KEY=$$(grep '^BESZEL_KEY=' $(SECRETS_DIR)/beszel.env | cut -d'=' -f2); \
	ssh -J $(PROXY) root@$(TRUENAS_IP) "pkill beszel-agent 2>/dev/null || true; cd $(REMOTE_DIR) && KEY='$$BESZEL_KEY' PORT=45876 nohup ./beszel-agent > beszel-agent.log 2>&1 &"
	@sleep 2
	@$(MAKE) status

down:
	@ssh -J $(PROXY) root@$(TRUENAS_IP) "pkill beszel-agent || echo 'Not running'"

logs:
	@ssh -J $(PROXY) root@$(TRUENAS_IP) "cat $(REMOTE_DIR)/beszel-agent.log | tail -50"

status:
	@ssh -J $(PROXY) root@$(TRUENAS_IP) "ps aux | grep '[b]eszel-agent' || echo 'Not running'"

restart: down up
