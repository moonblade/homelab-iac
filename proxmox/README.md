## Proxmox setup

Setup instructions for a new node added to homelab

## Install basics

- Install git and vim
- Install nix

```bash
apt install git vim
sh <(curl -L https://nixos.org/nix/install) --daemon
```

## Nvim

- Once nvim is installed, create `~/.config`, copy contents of `simplified-nvim-config` to it
- Run `PackerSync` to install plugins 

