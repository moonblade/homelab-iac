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
    resolutions = [1920x1200, 1920x1080, 1440x900, 1280x720]
    # PipeWire: explicitly set the virtual sink for audio capture.
    # pa_simple_new() fails without this when using pipewire-pulse compat layer.
    audio_sink = sink-sunshine-stereo
    # Disable touch/pen passthrough — not used for desktop streaming.
    # Pre-v2026.906 Sunshine has a bug where Touch/Pen uinput devices are not
    # destroyed on client disconnect, causing them to accumulate across sessions.
    # Each reconnect leaves orphaned devices that inject duplicate input events,
    # causing mouse desync and infinite key repeat. Fixed upstream in v2026.906
    # (PR #5368, libvirtualhid rewrite) but this stays as belt-and-suspenders.
    native_pen_touch = disabled
  '';

  # Daily Sunshine restart at 3am to clear any accumulated uinput state.
  # Belt-and-suspenders: native_pen_touch=disabled prevents Touch/Pen device
  # leaks, but Keyboard/Mouse passthrough devices are also affected in older
  # builds. Fixed upstream in v2026.906 (PR #5368) but kept as a safety net.
  systemd.user.services.sunshine-restart = {
    description = "Daily Sunshine restart to clear virtual input device state";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user restart sunshine.service";
    };
  };

  systemd.user.timers.sunshine-restart = {
    description = "Timer for daily Sunshine restart at 3am";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
    };
  };

  # Symlink config into place on activation
  system.activationScripts.sunshineConfig = ''
    mkdir -p /home/moonblade/.config/sunshine
    if [ ! -f /home/moonblade/.config/sunshine/sunshine.conf ]; then
      cp /etc/sunshine/sunshine.conf /home/moonblade/.config/sunshine/sunshine.conf
      chown moonblade:users /home/moonblade/.config/sunshine/sunshine.conf
    fi
  '';
}
