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

  # Persist Sunshine config across NixOS rebuilds
  # output_name left unset = auto-detect first connected display (HDMI-0 dummy plug)
  # nvenc fails on this GPU in KMS mode; Vulkan encoders (h264/hevc/av1_vulkan) work fine
  environment.etc."sunshine/sunshine.conf".text = ''
    min_bitrate = 20000
    fps = 60
    qp = 20
    adapter_name = NVIDIA GeForce RTX 5060 Ti
  '';

  # Symlink config into place on activation
  system.activationScripts.sunshineConfig = ''
    mkdir -p /home/moonblade/.config/sunshine
    if [ ! -f /home/moonblade/.config/sunshine/sunshine.conf ]; then
      cp /etc/sunshine/sunshine.conf /home/moonblade/.config/sunshine/sunshine.conf
      chown moonblade:users /home/moonblade/.config/sunshine/sunshine.conf
    fi
  '';
}
