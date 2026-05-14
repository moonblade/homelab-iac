SECRETS_FILE = ../../secrets/hades-ollama.tfvars
OLLAMA_IP = 192.168.29.74

init:
	terraform init

plan:
	terraform plan -var-file=$(SECRETS_FILE) -out=hades-ollama.tfplan

apply:
	terraform apply hades-ollama.tfplan

destroy:
	terraform destroy -var-file=$(SECRETS_FILE)

# Check Ollama status
status:
	ssh root@$(OLLAMA_IP) 'systemctl status ollama'

# Test Ollama API
test:
	curl -s http://$(OLLAMA_IP):11434/api/tags | python3 -m json.tool
