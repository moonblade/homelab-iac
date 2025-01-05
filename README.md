# HOMELAB - Infrastructure as Code

Homelab server infrastructure

### Athena

First server setup on the homelab. proxmox base.
k3s cluster on nixos vm.

##### NixOS Template

This image is the template for any future nixos installations. Bummed off of [jd's configuration](https://github.com/kmjayadeep/homelab-iac/blob/main/nixos-images/nixos-base-image/README.md).

##### Steps

- Can't build linux image of arm mac, so download the repo in proxmox and build it there.
- Clone the repo in proxmox
- Create nixos image with 

```bash
git clone https://github.com/moonblade/homelab-iac.git
cd homelab-iac
make build-nixos-template
make copy
```

In proxmox UI

- Go to datacenter->[node]->[storage]->backups
- Restore the image which was uploaded now
- Provide name, cpu, memory etc. Don't auto-start
- Open the new VM -> click on more -> convert to template

To test on ui

- click on base image -> more -> clone
- Once cloned, provide cloud-init parameters as needed
- Adjust hard-disk size as needed in hardware > disk actions > resize.
- start and test

#### Terraform

K3s vm is setup with terraform by cloning nixos-base image, and modifying values for cloud-init.
Works with terraform.

VM using nixos base image is saved as a module for reuse.

Run `make init`, `make plan`, `make apply` to setup the vm from within `athena/terraform`.

### Log

- Jan 5, 2025

Nixos template is used to setup a new vm with cloud-init for k3s.
Infra is saved as terraform file in athena/terraform

- Jan 4, 2025

Installed nix on my mac, and hoping to get a template setup for nixos for any future uses.
Couldn't get build to work on mac, so building it on proxmox instead.
Got build working on proxmox, and saved it as dump, used it to restore to a vm and converted it to template. Tested it in ui.
Need to try making it work with code now.

- Jan 1, 2025

Bought a lenovo thinkcenter to use as a homelab server recently.
Messing around by installing proxmox on it and getting some vms and k3s on it.

Primary use case would be to get my finance tracking on it and try plaintext accounting with beancounter as frontend.
With sms automation to automatically put stuff into the plaintext. Will see how that goes.

But along the way want to learn nixos configurations, run k3s on it and get most of my crap thats on the rpi server on k3s instead.
I have an ubuntu vm as well on it to mess around with as a normal linux machine. Will see how it goes. Wish me luck
