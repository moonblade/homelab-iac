# Hades (Proxmox Server)

Infrastructure-as-Code for the Proxmox host.

## Features

| Feature | Description |
|---------|-------------|
| `nginx-proxy-manager` | Reverse proxy with Let's Encrypt SSL for Proxmox web UI |

## Quick Start

```bash
# From repo root

# Deploy NPM with SSL (full setup)
make deploy-hades-npm

# Check status
make hades-npm-status

# View logs
make hades-npm-logs
```

## Prerequisites

- SSH access to `hadests` (Tailscale)
- Secrets in `../secrets/` (git-crypt encrypted)
