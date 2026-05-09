# Luna - NixOS Desktop VM

NixOS desktop VM running on **Athena** Proxmox with i3 window manager, Sunshine game streaming, and OpenCode AI coding assistant.

## Quick Start

```bash
# Deploy NixOS config changes
make deploy

# Authenticate Tailscale (first time only)
make tailscale

# Setup Oh My OpenCode (first time only)
ssh luna "bunx oh-my-opencode install"
```

## Access

- **SSH**: `ssh moonblade@192.168.1.199` or `ssh luna`
- **RDP**: Connect to `192.168.1.199:3389` with any RDP client
- **Moonlight**: Game streaming via Sunshine (pair at https://192.168.1.199:47990)

## VM Specs

- **Host**: Athena (Proxmox)
- **VMID**: 401
- **IP**: 192.168.1.199
- **CPU**: 6 vCPUs (1 socket × 6 cores)
- **RAM**: 8GB (balloon disabled)
- **Disk**: 100GB
- **Template**: nixos-base (migrated from Hades)

## NixOS Modules

Enable/disable features by editing `nixos/modules.nix`:

| Module | Description |
|--------|-------------|
| `desktop.nix` | X11 + i3 window manager |
| `i3config.nix` | i3 config with vim-style keybindings |
| `i3status-rust.nix` | Status bar (native i3bar integration) |
| `xrdp.nix` | Remote desktop access |
| `sunshine.nix` | Game streaming (Moonlight) |
| `audio.nix` | PulseAudio (xrdp audio) |
| `networking.nix` | Static IP config |
| `tailscale.nix` | VPN access |
| `user.nix` | moonblade user |
| `browsers.nix` | Firefox + Chrome |
| `tools.nix` | Desktop utilities + OpenCode |

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

Luna has OpenCode pre-installed for terminal-based AI coding assistance.

### First-time Setup

```bash
# Install Oh My OpenCode plugin
ssh luna "bunx oh-my-opencode install"
```

### Usage

```bash
# Start OpenCode in any git repo
opencode

# Or connect via SSH and use
ssh luna
cd ~/your-project
opencode
```

Config files:
- `~/.config/opencode/opencode.json` - Main config
- `~/.config/opencode/oh-my-opencode.json` - Agent configurations

## Flatpak Apps

Stremio and other apps requiring insecure dependencies are installed via Flatpak:

```bash
# Stremio (already installed)
flatpak run com.stremio.Stremio

# Install new Flatpak apps
flatpak install flathub <app-id>
```

## Media Key Forwarding (Mac → Luna)

Forward play/pause, next, previous from Mac to Luna even when RDP isn't focused.
Works with keyboard media keys, headset buttons, and AirPods ear detection.

### Mac Setup (one-time)

```bash
# Install skhd
brew install koekeishiya/formulae/skhd

# Start service
skhd --start-service

# Grant Accessibility permissions when prompted
# System Preferences → Privacy & Security → Accessibility → Add skhd
```

Config is at `~/.config/skhd/skhdrc` - forwards media keys to Luna via SSH + playerctl.

### Requirements

- SSH key auth to Luna (`ssh luna` must work without password)
- Luna must have playerctl installed (included in tools.nix)
- skhd needs Accessibility permissions on Mac

### Troubleshooting

```bash
# Check skhd is capturing keys
skhd --observe

# Check logs
cat /tmp/skhd_$USER.err.log

# Restart skhd after config changes
skhd --restart-service

# Test playerctl on Luna
ssh luna "DISPLAY=:0 playerctl status"
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
