#K3S_IP:=192.168.1.150
# K3S_IP:=100.100.145.85
 K3S_IP:=sirius.moonblade.work

copy:
	scp -r . root@${K3S_IP}:/etc/nixos/k3s

rebuild: copy
	ssh root@${K3S_IP} 'nixos-rebuild switch --flake /etc/nixos/k3s#sirius'
	scp root@${K3S_IP}:/root/.kube/config ~/.kube/sirius.yaml
	sed -i '' 's/127.0.0.1/${K3S_IP}/g' ~/.kube/sirius.yaml
	sed -i '' 's/default/sirius/g' ~/.kube/sirius.yaml

add-disks:
	ssh athena 'qm set 301 --scsi2 /dev/disk/by-uuid/d7604944-98cb-4baa-b616-089b1a27ce3e'
	ssh athena 'qm set 301 --scsi4 /dev/disk/by-uuid/337704f0-9587-44df-adb2-a61ba263d75c'
	# This one has problems, maybe dont use it
	# # ssh athena 'qm set 301 --scsi3 /dev/disk/by-uuid/d2ffd85b-dc75-4850-9df4-952d52d993a4'

tailscale:
	ssh athena 'sudo tailscale up --advertise-routes=192.168.1.0/24'
	echo "Go approve it in tailscale web interface > athena > subnets"
	# ssh root@${K3S_IP} 'sudo tailscale up --accept-dns=false --advertise-routes=192.168.1.0/24'
