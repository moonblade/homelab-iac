# Nginx Proxy Manager for Hades

Reverse proxy for Proxmox at `hades.moonblade.work` with Let's Encrypt SSL.

## One-Command Setup

From the `hades/` directory:

```bash
make nginx-proxy-manager
```

This automatically:
1. Deploys NPM container (v2.12.3 with host networking)
2. Installs certbot-dns-cloudflare plugin
3. Changes default admin password
4. Generates Let's Encrypt SSL certificate via Cloudflare DNS challenge
5. Creates proxy host for Proxmox with SSL enabled

## Architecture

```
Internet → hades.moonblade.work:443 (HTTPS)
                    ↓
         Nginx Proxy Manager (Docker, host network)
                    ↓
              127.0.0.1:8006
                    ↓
            Proxmox Web UI
```

## Endpoints

| Service | URL |
|---------|-----|
| Proxmox | https://hades.moonblade.work |
| NPM Admin | http://hades.moonblade.work:81 |

## Secrets

Credentials stored in `secrets/` (git-crypt encrypted):
- `secrets/npm-hades.env` - NPM admin credentials
- `secrets/cloudflare.env` - Cloudflare API token

## Manual Commands

| Command | Description |
|---------|-------------|
| `make deploy` | Deploy container only |
| `make setup` | Full setup (deploy + SSL + proxy) |
| `make status` | Check service status |
| `make logs` | View container logs |
| `make renew-cert` | Renew SSL certificate |

## Configuration

- **NPM Version**: 2.12.3 (required for certbot-dns-cloudflare)
- **Network Mode**: host (access Proxmox at 127.0.0.1:8006)
- **SSL**: Let's Encrypt via Cloudflare DNS challenge
- **WebSocket**: Enabled for Proxmox console/VNC
- **HTTP/2**: Enabled

## Troubleshooting

### "Connection error 401: No ticket"
Proxmox requires HTTPS for auth cookies. Run `make setup` to configure SSL.

### Certificate renewal
```bash
make renew-cert
```
