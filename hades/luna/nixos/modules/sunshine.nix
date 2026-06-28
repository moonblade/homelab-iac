# Sunshine module: Game streaming server (Moonlight compatible)
# GPU: NVIDIA RTX 5060 Ti passed through with x-vga=1 (Proxmox: qm set 401 --hostpci0 0000:01:00,pcie=1,x-vga=1)
{ config, lib, pkgs, ... }:

{
  # Sunshine via NixOS module - runs as a system service
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;  # Required for KMS display capture
  };

  # udev rules for virtual input (mouse/keyboard injection)
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  # Load uinput kernel module at boot
  boot.kernelModules = [ "uinput" ];

  # Add moonblade user to input group for uinput access
  users.users.moonblade.extraGroups = [ "input" "video" ];
}
