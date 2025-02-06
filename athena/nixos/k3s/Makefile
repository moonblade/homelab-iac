# K3S_IP:=sirius
# K3S_IP:=192.168.1.150
K3S_IP:=100.113.7.120

copy:
	scp -r . root@${K3S_IP}:/etc/nixos/k3s

rebuild: copy
	ssh root@${K3S_IP} 'nixos-rebuild switch --flake /etc/nixos/k3s#sirius'
	scp root@${K3S_IP}:/root/.kube/config ~/.kube/sirius.yaml
	sed -i '' 's/127.0.0.1/${K3S_IP}/g' ~/.kube/sirius.yaml
	sed -i '' 's/default/sirius/g' ~/.kube/sirius.yaml

add-disk:
	ssh athena 'qm set 301 --virtio1 /dev/sdb'

tailscale:
	ssh athena 'sudo tailscale up --advertise-routes=192.168.1.0/24'
	echo "Go approve it in tailscale web interface > athena > subnets"
	# ssh root@${K3S_IP} 'sudo tailscale up --accept-dns=false --advertise-routes=192.168.1.0/24'
