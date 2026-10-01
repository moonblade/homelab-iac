# Module configuration for terra desktop (Athena backup VM for Luna)
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
    ./modules/audio.nix        # PipeWire (required for xrdp audio)

    # Networking
    ./modules/networking.nix   # Static IP configuration
    ./modules/tailscale.nix    # VPN access

    # User & Tools
    ./modules/user.nix         # moonblade user configuration
    ./modules/browsers.nix     # Firefox + Chrome
    ./modules/tools.nix        # Essential desktop tools + OpenCode

    # Monitoring
    ./modules/beszel.nix       # Beszel monitoring agent

    # NOTE: Deliberately excluded vs. Luna (hades/luna) since Athena has no GPU:
    #   - sunshine.nix (game streaming needs GPU)
    #   - ollama.nix / hermes.nix (LLM inference needs GPU; would be painfully slow on CPU)
    #   - npm.nix (reverse proxy for ollama.moonblade.work - not applicable here)
    #   - steam.nix (gaming needs GPU)
    #   - bluetooth.nix (tied to Hades' specific USB dongle passthrough)
  ];
}
