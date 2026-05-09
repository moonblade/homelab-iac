# PROJECT KNOWLEDGE BASE

## OVERVIEW

Homelab infrastructure as code. Proxmox VMs, NixOS configurations, Terraform modules, and TrueNAS management.

## STRUCTURE

```
homelab-iac/
├── athena/               # First Proxmox server (6-core, 16GB RAM)
│   ├── nixos/            # NixOS templates
│   └── terraform/        # VM provisioning via Terraform
├── hades/                # Second Proxmox server (primary workloads)
│   ├── sirius/           # k3s cluster VM (VMID 301)
│   ├── luna/             # Desktop VM with Sunshine streaming (VMID 401, on Athena)
│   └── truenas/          # TrueNAS SCALE Terraform config
├── proxmox/              # Proxmox-level configurations
├── secrets/              # git-crypt encrypted secrets
└── terraform-modules/    # Reusable Terraform modules
```

## VM LOCATIONS

| VM | Host | VMID | IP | Purpose |
|----|------|------|-----|---------|
| Sirius | Hades | 301 | 192.168.1.200 | k3s cluster |
| Luna | Athena | 401 | 192.168.1.199 | NixOS desktop + Sunshine + OpenCode |
| TrueNAS | Hades | 201 | 192.168.1.10 | Storage |

## WORKFLOW RULES

1. **All changes via PR** - Never push directly to main. Create feature branch, open PR via `gh pr create`
2. **Log changes in README** - Add brief entry to README.md Log section for each change with date
3. **Wait for PR approval** - After creating a PR, wait for human to approve before merging. Do not auto-merge.
4. **Always rebuild with make commands** - Use `make deploy`, `make rebuild`, etc. Never run raw nixos-rebuild or terraform commands directly.

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Sirius (k3s) config | `hades/sirius/` | Rebuild with `make deploy` |
| Luna (desktop) config | `hades/luna/nixos/` | Rebuild with `make deploy` |
| TrueNAS config | `hades/truenas/` | `make plan && make apply` |
| Secrets | `secrets/` | git-crypt encrypted |

## CONVENTIONS

- **Terraform state**: Stored locally, protected with git-crypt
- **Secrets**: All in `secrets/` folder, git-crypt encrypted
- **Sensitive tfvars**: Use `-var-file=../../secrets/*.tfvars` pattern

## ANTI-PATTERNS

- **DO NOT** push directly to main - use PRs
- **DO NOT** commit unencrypted secrets
- **DO NOT** store Terraform state in plain text

## COMMANDS

```bash
# Luna desktop management
cd hades/luna
make deploy

# Sirius k3s management
cd hades/sirius
make deploy

# TrueNAS management  
cd hades/truenas
make init && make plan && make apply
```

## NOTES

- **Athena**: Lenovo ThinkCentre running Proxmox (6 cores, 16GB RAM). Hosts Luna desktop VM.
- **Hades**: Second Proxmox instance (12 cores, 32GB RAM). Hosts Sirius k3s and TrueNAS.
- **Luna**: NixOS desktop with i3, Sunshine game streaming, OpenCode AI assistant. IP 192.168.1.199.
- **Sirius**: k3s cluster for homelab services. IP 192.168.1.200.
- **TrueNAS**: 192.168.1.10, SCALE 25.10.1 (Fangtooth)
