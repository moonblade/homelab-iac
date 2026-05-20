build-nixos-template:
	make -C athena/nixos/nixos-template build
	make -C athena/nixos/nixos-template copy

init-athena:
	make -C athena/terraform init

plan-athena:
	make -C athena/terraform plan

apply-athena:
	make -C athena/terraform apply

destroy-athena:
	make -C athena/terraform destroy

ssh-remove:
	ssh-keygen -R sirius
	ssh-keygen -R 192.168.1.150

rebuild-sirius:
	make -C athena/nixos/k3s rebuild

copy:
	make -C athena/nixos/k3s copy

tailscale-sirius:
	make -C athena/nixos/k3s tailscale-sirius

run: rebuild-sirius

# Hades targets
deploy-hades-npm:
	make -C hades/nginx-proxy-manager deploy

hades-npm-status:
	make -C hades/nginx-proxy-manager status

hades-npm-logs:
	make -C hades/nginx-proxy-manager logs
