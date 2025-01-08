build-nixos-template:
	make -C athena/nixos/nixos-template build

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

