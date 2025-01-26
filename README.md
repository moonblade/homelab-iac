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
