# Luna - NixOS Desktop VM

NixOS desktop VM running on Hades Proxmox with i3 window manager and xrdp remote access.

## Quick Start

```bash
# Provision VM
make init
make plan
make apply

# After VM boots, deploy NixOS config
make deploy

# Authenticate Tailscale (first time only)
make tailscale
```

## Access

- **SSH**: `ssh moonblade@192.168.1.199` or `ssh luna`
- **RDP**: Connect to `192.168.1.199:3389` with any RDP client
  - Credentials in `secrets/hades-nixos-desktop.tfvars`

## VM Specs

- **IP**: 192.168.1.199
- **CPU**: 4 cores
- **RAM**: 16GB
- **Disk**: 100GB
- **Template**: nixos-base

## NixOS Modules

Enable/disable features by editing `nixos/modules.nix`:

| Module | Description |
|--------|-------------|
| `desktop.nix` | X11 + i3 window manager |
| `xrdp.nix` | Remote desktop access |
| `audio.nix` | PulseAudio (xrdp audio) |
| `networking.nix` | Static IP config |
| `tailscale.nix` | VPN access |
| `user.nix` | moonblade user |
| `browsers.nix` | Firefox + Chrome |
| `tools.nix` | Desktop utilities |

## i3 Quick Reference

| Key | Action |
|-----|--------|
| `Mod+Enter` | Open terminal (alacritty) |
| `Mod+d` | Application launcher (rofi) |
| `Mod+w` | Close window |
| `Mod+1-9` | Switch workspace |
| `Mod+Shift+1-9` | Move window to workspace |
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move window |
| `Mod+f` | Fullscreen |
| `Mod+v` | Split vertical |
| `Mod+b` | Split horizontal |
| `Mod+Shift+e` | Exit i3 |
| `Mod+Shift+r` | Restart i3 |

**Mod = Alt key**

## Flatpak Apps

Stremio and other apps requiring insecure dependencies are installed via Flatpak:

```bash
# Stremio (already installed)
flatpak run com.stremio.Stremio

# Install new Flatpak apps
flatpak install flathub <app-id>
```

## Rebuilding

After changing NixOS config:

```bash
make deploy
```

Or manually:
```bash
make copy
make rebuild
```
