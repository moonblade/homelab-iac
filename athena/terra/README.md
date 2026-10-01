# Terra - NixOS Desktop VM (Luna Backup)

NixOS desktop VM running on **Athena** Proxmox with i3 window manager and OpenCode AI coding assistant.

Smaller, underpowered sibling of Luna (`hades/luna`) — intended as a backup desktop
to use whenever Hades is down (it has had random reboots). No GPU, so no Sunshine
game streaming, no Ollama, no Steam. Access is via RDP only.

## Quick Start

```bash
# Deploy NixOS config changes
make deploy

# Authenticate Tailscale (first time only)
make tailscale
```

## Access

- **SSH**: `ssh moonblade@192.168.1.200` or `ssh terra`
- **RDP**: Connect to `192.168.1.200:3389` with any RDP client

## VM Specs

- **Host**: Athena (Proxmox) — note: Athena's host only has 16GB RAM total, so the
  VM is capped at 14GB to leave headroom for Proxmox itself.
- **VMID**: 402
- **IP**: 192.168.1.200
- **CPU**: 4 vCPUs (1 socket × 4 cores)
- **RAM**: 14GB (balloon disabled)
- **Disk**: 80GB
- **Template**: nixos-base

## NixOS Modules

Enable/disable features by editing `nixos/modules.nix`:

| Module | Description |
|--------|-------------|
| `desktop.nix` | X11 + i3 window manager (no GPU BusID hack) |
| `i3config.nix` | i3 config with vim-style keybindings |
| `i3status-rust.nix` | Status bar (native i3bar integration) |
| `xrdp.nix` | Remote desktop access |
| `audio.nix` | PipeWire (xrdp audio) |
| `networking.nix` | Static IP config |
| `tailscale.nix` | VPN access |
| `user.nix` | moonblade user |
| `browsers.nix` | Firefox + Chrome |
| `tools.nix` | Desktop utilities + OpenCode |
| `beszel.nix` | Monitoring agent |

Deliberately **excluded** vs. Luna (no GPU on Athena):
`sunshine.nix`, `ollama.nix`, `hermes.nix`, `npm.nix`, `steam.nix`, `bluetooth.nix`
(the bluetooth module is tied to Hades' specific USB dongle passthrough).

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

## OpenCode (AI Coding Assistant)

Terra has OpenCode pre-installed for terminal-based AI coding assistance (same as Luna).

```bash
# Install Oh My OpenCode plugin (first time only)
ssh terra "bunx oh-my-opencode install"

# Start OpenCode in any git repo
ssh terra
cd ~/your-project
opencode
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

## First-time Provisioning

```bash
cd athena/terra
make init
make plan
make apply
make deploy
make tailscale
```

## Log

- **2026-10-01**: Initial creation — smaller backup desktop for Luna on Athena, 14GB RAM / 4 cores, no GPU.
