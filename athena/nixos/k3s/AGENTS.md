# K3S NIXOS CONFIGURATION

**Generated:** 2026-02-21
**Commit:** 6e53354
**Branch:** main

## OVERVIEW

NixOS flake configuration for "sirius" - a single-node k3s cluster running on Proxmox VM. Manages k8s, networking (Tailscale, Cloudflared), and shell environment.

## STRUCTURE

```
k3s/
├── flake.nix           # Entry point - defines sirius nixosConfiguration
├── configuration.nix   # Base system: boot, network, storage, packages
├── Makefile            # Deploy commands (copy → rebuild → fetch kubeconfig)
├── modules/            # NixOS modules (one feature per file)
│   ├── k3s.nix         # K3s + Docker runtime config
│   ├── cloudflared.nix # Cloudflare tunnel ingress
│   ├── tailscale.nix   # Tailscale VPN + IP forwarding
│   ├── user.nix        # Users: operator, media
│   ├── zsh.nix         # Shell: oh-my-zsh, aliases
│   └── nvim.nix        # Editor: neovim + packer
└── secrets/            # Cloudflared credentials (git-tracked)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add new service | `modules/` | Create `<service>.nix`, add to `flake.nix` imports |
| Change k3s flags | `modules/k3s.nix` | `extraFlags` array |
| Add domain route | `modules/cloudflared.nix` | `ingress` block |
| Change static IP | `configuration.nix` | `networking.interfaces.ens18` |
| Add storage mount | `configuration.nix` | `fileSystems` section |
| Deploy changes | `make rebuild` | Copies to host, runs nixos-rebuild |

## KEY CONFIGURATION

**K3s Setup** (modules/k3s.nix):
- Docker runtime (not containerd)
- Disabled: traefik, servicelb, metrics-server, local-storage, helm-controller
- Network: flannel host-gw, IPVS proxy mode
- CIDRs: pods=10.42.0.0/16, services=10.43.0.0/16
- TLS SANs: sirius.moonblade.work, siriusk8s.moonblade.work

**Network Topology**:
- Static IP: 192.168.1.150 (ens18)
- Cloudflared routes *.moonblade.work → 192.168.1.200 (k8s ingress)
- siriusk8s.moonblade.work → localhost:6443 (API server via tunnel)

## CONVENTIONS

- One module = one feature (no mixing concerns)
- Module signature: `{ config, lib, pkgs, ... }: { ... }`
- Secrets: plaintext in `secrets/` (this is homelab, not prod)
- IP addresses: hardcoded (192.168.1.x subnet)

## ANTI-PATTERNS

- **NO Helm charts here** - k3s helm-controller disabled; manage charts separately
- **NO kustomize** - pure NixOS modules
- **DO NOT** use containerd - Docker runtime required (--docker flag)
- Commented code in `configuration.nix` line 32-36: external drive has problems, don't enable

## COMMANDS

```bash
# Deploy configuration to sirius
make rebuild

# Just copy files without rebuilding
make copy

# Get kubeconfig after rebuild
# (automatically done by make rebuild)

# Add physical disks to Proxmox VM
make add-disks

# Manual tailscale setup
make tailscale
```

## NOTES

- **Longhorn compatibility**: iscsi symlinks created in activationScripts
- **DNS**: Uses 8.8.8.8, Tailscale DNS disabled (--accept-dns=false)
- **Firewall disabled** - relies on network isolation
- `K3S_IP` in Makefile uses sirius.moonblade.work (Tailscale/Cloudflared)
