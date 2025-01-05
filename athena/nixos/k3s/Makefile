K3S_IP:=192.168.1.150

rebuild:
	scp -r . root@${K3S_IP}:/etc/nixos/
	ssh root@${K3S_IP} 'nixos-rebuild switch --flake /etc/nixos#sirius'

