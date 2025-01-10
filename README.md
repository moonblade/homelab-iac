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

- Jan 10, 2025

Was trying to get shared access to drives via nfs, so original plan was the mount the same drive in nixos, crashed and burned hard. Got my nixos vm fucked up enough that I couldn't do any proxmox operations like shutdown or see console on it.
Whelp another reset of the entire infra later, I'm more convinced than ever that I can't give it independant storage that will just evaporate when I do the next terraform destroy and that clock is definitely ticking.
So need to setup data on proxmox and share it with the cluster. So option two, nfs. Setup an nfs drive on proxmox that accesses the external lvm group drive and then shared that on the network.
tried it out on the ubuntu vm for starters and it worked. confident tried it manually on nixos and that worked. So updated config and rebooted nixos. And damn it worked. Nice.

Now I can either use hostpath or setup nfs drives within the cluster to get access to the same thing.

Since my storage is gonna come through nfs, I'm removing the extra drive I added that was isolated for k3s, instead it can work with the original premium 100 gb ssd space that it has.
External space needs will be filled by the nfs path.

- Jan 9, 2025

Had gotten more issues with dns not resolving within the cluster, so I'm gonna assume its to do with the machine, so trying to get resolved setup properly. After editing config I also linked the resolved file to it. Will see what happens.
`sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf`

Realized why sometimes reboot causes issues, for some reasons even with cloudinit providing ip, ip isn't static, so ip was being changed. So made static ip in configuration.nix as well. hopefully that particular issue is solved.
Figured it out by setting up a password when I had access and then logging in via proxmox ui and checking ip, then had the oh shit moment since I hadn't even thought that with cloud init given ip could change at all. Oh well.

- Jan 8, 2025

Wanted tailcale to be setup automatically (the key dies in 90 days, oh well, its still better than nothing I guess). Aaaaaand sirius is unresponsive. well terraform destroy and recreate.
:shrug:. I definitely need to add some failsafe to connect to it if network crap goes down.

To reset can run the following, sigh I need to be better at debugging

```bash
make destroy-athena
make plan-athena
make apply-athena
make ssh-remove
sleep 5
make rebuild-sirius
```

Ask me how I know the above. Its not my configuration thats the issue. its something in either proxmox or the vm thats the issue. No clue what it could be. This will be an issue. for now ignoring it.
I'm giving up on it, I just used passwd to create a passwd and next time this happens I hope I'll be able to use ui to login and reset it.

- Jan 6, 2025

Tried setting up ubuntu directly via iso, which worked. Then tried to do that with terraform, ran into issues during setup.
So used the iso to create a template and then use that. but still got crappy issues cropping up. so instead dropped all of it and set it up manually.
If i end up needing to setup it more and more will do it then or try nixos instead.

Going to setup fluxcd with github bootstrapping. Ip was wrong on nixos config, so fixed that and restarted.
Got a basic [fluxcd bootstrap running](https://github.com/moonblade/homelab-k8s/tree/main).

- Jan 5, 2025

Nixos template is used to setup a new vm with cloud-init for k3s.
Infra is saved as terraform file in athena/terraform
I tried to attach the external hard disk to it, it ended up freezing and not responding whatsoever.
Had to reset the entire proxmox server and recreate sirius from scratch.
Then realized that I had setup the lvm wrong, so recreated the lvm. Had to do that a few times to figure out why it was fully used up, instead of thin provisioning was just provisioning the whole thing, so it couldn't be used.
Ended up with just provisioning a tiny bit and the rest is available for others now. Though this method doesn't allow cross sharing. Will see about that.

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
