# Module configuration for ares VM
# SSH-focused - no xrdp, audio, or browsers
# Enable/disable features by commenting out imports

{ config, lib, pkgs, ... }:

{
  imports = [
    # Desktop Environment
    ./modules/desktop.nix      # X11 + i3 window manager
    ./modules/i3config.nix     # i3 config with vim-style keybindings
    ./modules/i3status-rust.nix # Status bar (native i3bar integration)
    # NOTE: xrdp.nix and audio.nix removed - SSH-focused VM
    
    # Networking
    ./modules/networking.nix   # Static IP configuration
    ./modules/tailscale.nix    # VPN access
    
    # User & Tools
    ./modules/user.nix         # moonblade user configuration
    ./modules/tools.nix        # CLI tools (simplified - no browsers/GUI apps)
  ];
}
