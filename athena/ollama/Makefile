SECRETS_FILE = ../../secrets/athena-ollama.tfvars
OLLAMA_IP = 192.168.1.198

init:
	terraform init

plan:
	terraform plan -var-file=$(SECRETS_FILE) -out=athena-ollama.tfplan

apply:
	terraform apply athena-ollama.tfplan

destroy:
	terraform destroy -var-file=$(SECRETS_FILE)

# Post-provision: install Ollama in the LXC container
setup-ollama:
	ssh root@$(OLLAMA_IP) 'apt-get update && apt-get install -y curl && curl -fsSL https://ollama.com/install.sh | sh'
	ssh root@$(OLLAMA_IP) 'systemctl enable ollama && systemctl start ollama'
	ssh root@$(OLLAMA_IP) 'ollama pull gemma4:e2b'

# Check Ollama status
status:
	ssh root@$(OLLAMA_IP) 'systemctl status ollama'

# Test Ollama API
test:
	curl -s http://$(OLLAMA_IP):11434/api/tags | python3 -m json.tool
