K3S_IP:=192.168.1.150

rebuild:
	scp -r . root@${K3S_IP}:/etc/nixos/k3s
	ssh root@${K3S_IP} 'nixos-rebuild switch --flake /etc/nixos/k3s#sirius'
	scp root@${K3S_IP}:/root/.kube/config ~/.kube/sirius.yaml
	sed -i '' 's/127.0.0.1/sirius/g' ~/.kube/sirius.yaml
	sed -i '' 's/default/sirius/g' ~/.kube/sirius.yaml
