# Sunshine module: Game streaming server (Moonlight compatible)
{ config, lib, pkgs, ... }:

{
  # Sunshine game streaming server
  services.sunshine = {
    enable = true;
    
    # Auto-start on boot
    autoStart = true;
    
    # Open firewall ports for streaming
    # Default ports: 47984-47990 TCP/UDP, 48010 TCP
    openFirewall = true;
    
    # Required for KMS/DRM display capture
    # Creates security wrapper with cap_sys_admin capability
    capSysAdmin = true;
  };
  
  # udev rules for virtual input devices (uinput)
  # Required for Sunshine to create virtual mouse/keyboard
  services.udev.extraRules = ''
    # Allow users in input group to access uinput
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';
  
  # Ensure uinput module is loaded
  boot.kernelModules = [ "uinput" ];
}
