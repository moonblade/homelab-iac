# K3S_IP:=sirius
K3S_IP:=192.168.1.150

rebuild:
	scp -r . root@${K3S_IP}:/etc/nixos/k3s
	ssh root@${K3S_IP} 'nixos-rebuild switch --flake /etc/nixos/k3s#sirius'
	scp root@${K3S_IP}:/root/.kube/config ~/.kube/sirius.yaml
	sed -i '' 's/127.0.0.1/${K3S_IP}/g' ~/.kube/sirius.yaml
	sed -i '' 's/default/sirius/g' ~/.kube/sirius.yaml

tailscale:
	ssh athena 'sudo tailscale up --advertise-routes=192.168.1.0/24'
	# ssh root@${K3S_IP} 'sudo tailscale up --accept-dns=false --advertise-routes=192.168.1.0/24'
