# PROJECT KNOWLEDGE BASE

## OVERVIEW

Homelab infrastructure as code. Proxmox VMs, NixOS configurations, Terraform modules, and TrueNAS management.

## STRUCTURE

```
homelab-iac/
├── athena/               # First Proxmox server
│   ├── nixos/            # NixOS VM configurations (k3s cluster "sirius")
│   └── terraform/        # VM provisioning via Terraform
├── hades/                # Second server (Proxmox VM with TrueNAS)
│   └── truenas/          # TrueNAS SCALE Terraform config
├── proxmox/              # Proxmox-level configurations
├── secrets/              # git-crypt encrypted secrets
└── terraform-modules/    # Reusable Terraform modules
```

## WORKFLOW RULES

1. **All changes via PR** - Never push directly to main. Create feature branch, open PR via `gh pr create`
2. **Log changes in README** - Add brief entry to README.md Log section for each change with date
3. **Wait for PR approval** - After creating a PR, wait for human to approve before merging. Do not auto-merge.

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Provision Athena VMs | `athena/terraform/` | `make plan && make apply` |
| NixOS config | `athena/nixos/k3s/` | Rebuild with `make rebuild-sirius` |
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
# Athena VM management
cd athena/terraform
make init && make plan && make apply

# TrueNAS management  
cd hades/truenas
make init && make plan && make apply

# Rebuild NixOS
make rebuild-sirius
```

## NOTES

- **Athena**: Lenovo ThinkCentre running Proxmox
- **Hades**: Second Proxmox instance with TrueNAS SCALE VM
- **TrueNAS**: 192.168.1.10, SCALE 25.10.1 (Fangtooth)
