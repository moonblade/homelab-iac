# xrdp module: Remote desktop access
{ config, lib, pkgs, ... }:

{
  # xrdp remote desktop server
  services.xrdp = {
    enable = true;
    
    # Use i3 as the window manager for RDP sessions
    # CRITICAL: Must use absolute path
    # Note: i3-gaps was merged into i3 upstream
    defaultWindowManager = "${pkgs.i3}/bin/i3";
    
    # Standard RDP port
    port = 3389;
    
    # Automatically open firewall
    openFirewall = true;
    
    # Enable audio over RDP (requires PulseAudio, not PipeWire)
    audio.enable = true;
  };

  # Note: PAM configuration is handled by the xrdp module itself
  # No need to override security.pam.services.xrdp-sesman

  # Ensure firewall allows RDP even if openFirewall doesn't work
  networking.firewall.allowedTCPPorts = [ 3389 ];
}
