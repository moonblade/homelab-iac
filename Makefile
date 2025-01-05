build-nixos-template:
	make -C athena/nixos/nixos-template build

plan-athena:
	make -C athena/terraform plan

apply-athena:
	make -C athena/terraform apply

destroy-athena:
	make -C athena/terraform destroy

rebuild-sirius:
	make -C athena/nixos/k3s rebuild

