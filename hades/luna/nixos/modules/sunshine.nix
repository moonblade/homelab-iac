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
  # /dev/uinput is owned by group "uinput" — must use that group, not "input"
  # ID_INPUT_KEYBOARD=1 tells libinput to treat sunshine's virtual keyboard as real,
  # preventing it from being silently disabled (libinput Send Events Mode = 0).
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    SUBSYSTEM=="input", ATTRS{name}=="Keyboard passthrough", ENV{ID_INPUT_KEYBOARD}="1", ENV{LIBINPUT_DEVICE_GROUP}="sunshine"
  '';

  # Load uinput kernel module at boot
  boot.kernelModules = [ "uinput" ];

  # uinput group for /dev/uinput access (sunshine virtual keyboard/mouse)
  users.groups.uinput = {};

  # Add moonblade to both input and uinput groups
  users.users.moonblade.extraGroups = [ "input" "uinput" "video" ];

  # Persist Sunshine config across NixOS rebuilds
  # capture = x11: NVIDIA proprietary Xorg bypasses KMS so DRM planes are always null.
  # X11 capture works correctly. nvenc/vulkan don't work with x11 capture; libx264 (software) is used.
  environment.etc."sunshine/sunshine.conf".text = ''
    min_bitrate = 20000
    fps = 60
    qp = 20
    adapter_name = NVIDIA GeForce RTX 5060 Ti
    capture = x11
    resolutions = [1440x900, 1920x1080, 1280x720]
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
