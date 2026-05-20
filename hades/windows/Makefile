HADES_IP = 192.168.1.73
VMID = 202

# VM management
start:
	ssh root@$(HADES_IP) 'qm start $(VMID)'

stop:
	ssh root@$(HADES_IP) 'qm stop $(VMID)'

status:
	ssh root@$(HADES_IP) 'qm status $(VMID)'

config:
	ssh root@$(HADES_IP) 'qm config $(VMID)'

# GPU management
gpu-status:
	ssh root@$(HADES_IP) 'lspci -nnk -s 01:00'
