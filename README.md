# HOMELAB - Infrastructure as Code

Homelab server infrastructure

## Proxmox

## NixOS Template

This image is the template for any future nixos installations. Bummed off of [jd's configuration](https://github.com/kmjayadeep/homelab-iac/blob/main/nixos-images/nixos-base-image/README.md).

#### Steps

- Can't build linux image of arm mac, so download the repo in proxmox and build it there.
- Clone the repo in proxmox
- Create nixos image with 

```bash
git clone https://github.com/moonblade/homelab-iac.git
cd homelab-iac
make build-nixos-template
make copy
```

### Log

- Jan 4, 2025

Installed nix on my mac, and hoping to get a template setup for nixos for any future uses.
Couldn't get build to work on mac, so building it on proxmox instead.

- Jan 1, 2025

Bought a lenovo thinkcenter to use as a homelab server recently.
Messing around by installing proxmox on it and getting some vms and k3s on it.

Primary use case would be to get my finance tracking on it and try plaintext accounting with beancounter as frontend.
With sms automation to automatically put stuff into the plaintext. Will see how that goes.

But along the way want to learn nixos configurations, run k3s on it and get most of my crap thats on the rpi server on k3s instead.
I have an ubuntu vm as well on it to mess around with as a normal linux machine. Will see how it goes. Wish me luck
