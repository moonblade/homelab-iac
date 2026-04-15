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

## Notes for future me.

1. The hard disks are connected on the host machine and then passed to the VM as SCSI drives.
Use the `make -C athena/nixos/k3s add-disks` command to add the disks to the VM.

Sigh, the 2TB disk I both, the 3.5 inch one is a piece of shit, keeps giving input output error right when I need it to perform.
So for now adding all of it on the same disk. Hopefully will get some different option later.

If this doesn't make me invest in a NAS, prolly nothing will

### Log

- **Jan 1, 2025**  
  Bought a Lenovo ThinkCentre to use as a homelab server recently.  
  Messing around by installing Proxmox on it and getting some VMs and k3s on it.  

  Primary use case would be to get my finance tracking on it and try plaintext accounting with Beancounter as the frontend. With SMS automation to automatically put stuff into plaintext. Will see how that goes.  

  Along the way, I want to learn NixOS configurations, run k3s on it, and get most of my stuff that's on the RPi server on k3s instead. I also have an Ubuntu VM to mess around with as a normal Linux machine. Wish me luck.  

- **Jan 4, 2025**  
  Installed Nix on my Mac, and hoping to get a template set up for NixOS for future uses. Couldn't get the build to work on Mac, so I built it on Proxmox instead. Got the build working on Proxmox, saved it as a dump, used it to restore to a VM, and converted it into a template. Tested it in the UI.  
  Need to try making it work with code now.  

- **Jan 5, 2025**  
  NixOS template is used to set up a new VM with cloud-init for k3s.  
  Infra is saved as a Terraform file in `athena/terraform`.  

  Tried to attach the external hard disk to it, but it ended up freezing and not responding whatsoever.  
  Had to reset the entire Proxmox server and recreate Sirius from scratch.  

  Realized I had set up the LVM wrong, so recreated it. Had to do that a few times to figure out why it was fully used up—instead of thin provisioning, I was just provisioning the whole thing, so it couldn't be used.  
  Ended up with provisioning a tiny bit, leaving the rest available for others. This method doesn't allow cross-sharing though. Will revisit later.  

- **Jan 6, 2025**  
  Tried setting up Ubuntu directly via ISO, which worked. Then tried to do that with Terraform, but ran into issues during setup.  
  Used the ISO to create a template, then used that—but still ran into crappy issues. Dropped everything and set it up manually. If I end up needing to set it up more, I'll address it then or try NixOS instead.  

  Set up FluxCD with GitHub bootstrapping. IP was wrong in the NixOS config, so I fixed that and restarted.  
  Got a basic [FluxCD bootstrap running](https://github.com/moonblade/homelab-k8s/tree/main).  

- **Jan 8, 2025**  
  Wanted Tailscale to be set up automatically (the key expires in 90 days—oh well, still better than nothing).  
  Sirius became unresponsive. Terraform destroy and recreate. :shrug:  

  I need to add a failsafe to connect if network issues arise.  
  To reset, I can run the following:  

  ```bash
  make destroy-athena
  make plan-athena
  make apply-athena
  make ssh-remove
  sleep 5
  make rebuild-sirius
  ```  

  It's not my configuration that's the issue; it's something in either Proxmox or the VM. For now, I'm ignoring it.  
  Used `passwd` to create a password and hope I'll be able to use the UI to reset next time.  

- **Jan 9, 2025**  
  Got more issues with DNS not resolving within the cluster. Linked the resolved file:  
  ```bash
  sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
  ```  

  Realized the IP wasn't static, even with cloud-init providing it. Made it static in `configuration.nix`.  
  Discovered this by setting a password, logging in via Proxmox UI, and checking the IP—had an "oh shit" moment when I realized the IP could change. Fixed it.  

- **Jan 10, 2025**  
  Tried getting shared access to drives via NFS. Mounted the same drive in NixOS, but it crashed hard.  
  My NixOS VM got messed up enough that I couldn't perform any Proxmox operations like shutdown or console access.  

  After resetting the entire infra, I'm convinced I can't give independent storage that will evaporate on the next Terraform destroy.  
  Option two: set up data on Proxmox and share it with the cluster via NFS.  
  Tested it on the Ubuntu VM—worked. Manually tested on NixOS—worked. Updated config and rebooted NixOS—worked. Nice.  

  Now I can use either hostPath or set up NFS drives within the cluster.  
  Since storage will come via NFS, I'm removing the extra drive isolated for k3s. It'll use the original premium 100GB SSD space, and external needs will be filled via the NFS path.  

- **Jan 11, 2025**  
  Debugging why Transmission on the cluster was throwing random folder creation errors. Turned out to be the drives—both of them.  

  Gave the drives back and ordered a fresh one. Lesson learned: don't use bad drives. Already spent close to 20k trying to save money by running my fiscal calculation app on this server.  
  Debugging the dual-drive issue was painful.  

- **Jan 12, 2025**  
  Bought a new 2TB hard disk after learning the hard way about skimping on quality.  

  Accidentally bought a 3.5-inch drive instead of a 2.5-inch one. and its non returnable.
  It needs an external power supply, rendering my previous enclosures useless. Sigh. This project on fiscal responsibility is becoming a prime example of what not to do  to be fiscally responsible.

  Since I had no other choice got an external enclosure for it and a multiplug and connected it to my setup and added it as a thinvolume and mounted it.

- **Jan 14, 2025**

The disk is going to be the death of me. Can't figure out why its not working with transmission or longhorn. Removed any use of lvm and connecting directly now. Its not helping much though.

- **Jan 24, 2025**

Made a script to connect or disconnect the hard disk as its available to the vm, hopefully that should make it work when available.

- **Jan 25, 2025**

Added nvim and zsh, removing readding and configuring ipv6 did nothing, and cilium, no cilium, flannel nothing works, so gonna go broke with no ipv6.

- **Jan 27, 2025**

Changed to use nfs share instead, the disk is a piece of shit, I need to get a better disk.

- **Feb 9, 2025**

Nfs has issues. I bought another disk. and connected it as a scsi drive on host. Mounted it and using that as hostpath now. Will try and setup nfs on rpi onc I have it.

```
qm set 301 -scsi2 /dev/disk/by-uuid/d7604944-98cb-4baa-b616-089b1a27ce3e
qm set 301 -scsi3 /dev/disk/by-uuid/d2ffd85b-dc75-4850-9df4-952d52d993a4
```

for scsi setup

I should update the terraform for it probably



- **Feb 23, 2026**

Gateway API migration: Updated cloudflared.nix to use default route (192.168.1.201) for all apps. Removed all explicit app routes (browse, homer, jackett, login, n8n, transmission, weave) - only k8s API and SSH remain as explicit routes. All apps now routed through nginx-gateway-fabric.

- **Mar 3, 2026**

TrueNAS config backup: Added automated backup of primary/root/config dataset to secondary pool. Daily snapshots at 2 AM (14 day retention) with local replication to secondary/config-backup (30 day retention).

NixOS desktop VM (Luna): Created new NixOS desktop VM on Hades for daily use as Windows replacement. Features i3 window manager with xrdp remote access, Firefox + Chrome browsers, Tailscale VPN, PulseAudio. Modular NixOS config in `hades/luna/`. VM ID 401, static IP 192.168.1.199, Tailscale at luna.moonblade.work.

- **Mar 8, 2026**

~~NixOS dev VM (Ares): Created lightweight NixOS VM on Hades for opencode/openclaw development. SSH-focused - no xrdp, audio, or browsers. Features i3 window manager, Tailscale VPN, NFS mount to TrueNAS, dev tools (Node.js, Python, Rust, Go). VM ID 402, 4GB RAM, 2 cores, static IP 192.168.1.197. Config in `hades/ares/`.~~

Removed Ares VM - no longer needed.

- **Mar 12, 2026**

Luna: Added Sunshine game streaming server for Moonlight client support. Enables low-latency game streaming from Luna to any Moonlight-compatible device.

- **Mar 26, 2026**

IaC sync with reality: Moved Sirius (k3s) terraform config from athena/ to hades/sirius/ to reflect actual VM location (VMID 301 on Hades). Updated disk size to 150G. Added sockets variable to proxmox-vm-qemu module. Fixed Luna config to match reality (8GB RAM, 2 sockets) and increased CPU from 4 to 6 cores (12 vCPU total) to address CPU throttling issues.

- **Mar 28, 2026**

Luna migration to Athena: Moved Luna VM from Hades to Athena to resolve memory balloon issues causing system freezes during Moonlight streaming. Removed unused ubuntu and nixos-base VMs from Athena to free resources. Luna now has dedicated 8GB RAM (balloon disabled), 6 vCPUs (reduced from 12 due to Athena's 6-core limit). Added OpenCode and Oh My OpenCode to Luna's NixOS config for AI-assisted development.

- **Apr 2, 2026**

USB storage expansion: Added two USB drives to TrueNAS via SCSI passthrough from Hades. Created usb-ssd pool (931GB SanDisk Extreme SSD) and usb-hdd pool (931GB 1TB HDD). Each pool has media and downloads datasets with NFS shares for k3s access. Updated Terraform config to document new storage layout.

- **Apr 5, 2026**

TrueNAS: Added Kestra storage dataset (primary/root/storage/kestra) with NFS share, daily snapshots at 4 AM, and replication to secondary/kestra-backup.

- **Apr 14, 2026**

Tailscale subnet routing for Sirius: Added `tailscale-sirius` make target to advertise 192.168.1.0/24 subnet from Sirius (nixos-2). This allows accessing internal *.sirius.moonblade.work URLs via Tailscale when outside the LAN. Run `make tailscale-sirius` and approve the subnet in Tailscale admin console.
