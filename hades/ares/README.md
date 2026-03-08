# Ares - NixOS Development VM

NixOS VM running on Hades Proxmox with i3 window manager. SSH-focused development machine for opencode/openclaw.

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

- **SSH**: `ssh moonblade@192.168.1.197` or `ssh ares`
- **Tailscale**: `ssh arests` (via Tailscale network)

## VM Specs

| Spec | Value |
|------|-------|
| **VM ID** | 402 |
| **IP** | 192.168.1.197 |
| **CPU** | 2 cores |
| **RAM** | 4GB |
| **Disk** | 100GB |
| **Template** | nixos-base |

## NixOS Modules

Enable/disable features by editing `nixos/modules.nix`:

| Module | Description |
|--------|-------------|
| `desktop.nix` | X11 + i3 window manager |
| `i3config.nix` | i3 config with vim-style keybindings |
| `i3status-rust.nix` | Modern status bar (Catppuccin theme) |
| `networking.nix` | Static IP config |
| `tailscale.nix` | VPN access |
| `user.nix` | moonblade user |
| `tools.nix` | CLI tools + dev environment |

**Removed from Luna** (SSH-focused):
- `xrdp.nix` - No remote desktop needed
- `audio.nix` - No audio needed
- `browsers.nix` - No browsers needed

## Development Tools

Pre-installed for opencode/openclaw development:

- Node.js 22 LTS
- Python 3
- Rust (via rustup)
- Go
- Git + GitHub CLI
- Neovim
- lazygit, delta, fzf

## i3 Quick Reference

| Key | Action |
|-----|--------|
| `Mod+Enter` | Open terminal (alacritty) |
| `Mod+d` | Application launcher (rofi) |
| `Mod+q` | Close window |
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

## NFS Mount

TrueNAS storage is available at `/mnt/nas` (auto-mounts on first access).

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
