build:
	nix build .#packages.x86_64-linux.proxmox --system x86_64-linux

copy:
	cp result/vzdump-qemu-nixos-*.vma.zst /var/lib/vz/dump/
