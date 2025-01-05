build-nixos-template:
	make -C athena/nixos/nixos-template build

plan-athena:
	make -C athena/terraform plan

apply-athena:
	make -C athena/terraform apply
