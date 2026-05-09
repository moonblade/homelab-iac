# Module configuration for luna desktop
# Enable/disable features by commenting out imports
# This file is the central place to toggle modules

{ config, lib, pkgs, ... }:

{
  imports = [
    # Desktop Environment
    ./modules/desktop.nix      # X11 + i3 window manager
    ./modules/i3config.nix     # i3 config with vim-style keybindings
    ./modules/i3status-rust.nix # Status bar (native i3bar integration)
    ./modules/xrdp.nix         # Remote desktop access
    ./modules/sunshine.nix     # Game streaming (Moonlight)
    ./modules/audio.nix        # PulseAudio (required for xrdp audio)
    
    # Networking
    ./modules/networking.nix   # Static IP configuration
    ./modules/tailscale.nix    # VPN access
    ./modules/beszel.nix       # Server monitoring agent
    
    # User & Tools
    ./modules/user.nix         # moonblade user configuration
    ./modules/browsers.nix     # Firefox + Chrome
    ./modules/tools.nix        # Essential desktop tools
  ];
}
