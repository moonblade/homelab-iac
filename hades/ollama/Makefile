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

# Post-provision: configure GPU passthrough in LXC config
setup-gpu:
	ssh root@192.168.29.73 'cat >> /etc/pve/lxc/501.conf << EOF

# NVIDIA GPU passthrough
lxc.cgroup2.devices.allow: c 195:* rwm
lxc.cgroup2.devices.allow: c 508:* rwm
lxc.cgroup2.devices.allow: c 511:* rwm
lxc.mount.entry: /dev/nvidia0 dev/nvidia0 none bind,optional,create=file
lxc.mount.entry: /dev/nvidiactl dev/nvidiactl none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm dev/nvidia-uvm none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm-tools dev/nvidia-uvm-tools none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-caps/nvidia-cap1 dev/nvidia-caps/nvidia-cap1 none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-caps/nvidia-cap2 dev/nvidia-caps/nvidia-cap2 none bind,optional,create=file
EOF'
	ssh root@192.168.29.73 'pct stop 501 && pct start 501'

# Post-provision: install NVIDIA drivers + Ollama in the LXC container
setup-ollama:
	ssh root@$(OLLAMA_IP) 'apt-get update && apt-get install -y curl wget gnupg2'
	ssh root@$(OLLAMA_IP) 'wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb -O /tmp/cuda-keyring.deb && dpkg -i /tmp/cuda-keyring.deb && apt-get update && apt-get install -y nvidia-utils-595-server libnvidia-compute-595-server'
	ssh root@$(OLLAMA_IP) 'curl -fsSL https://ollama.com/install.sh | sh'
	ssh root@$(OLLAMA_IP) 'systemctl enable ollama && systemctl start ollama'
	ssh root@$(OLLAMA_IP) 'ollama pull gemma4:e2b'

# Check Ollama status
status:
	ssh root@$(OLLAMA_IP) 'systemctl status ollama'

# Check GPU inside LXC
gpu:
	ssh root@$(OLLAMA_IP) 'nvidia-smi'

# Test Ollama API
test:
	curl -s http://$(OLLAMA_IP):11434/api/tags | python3 -m json.tool
