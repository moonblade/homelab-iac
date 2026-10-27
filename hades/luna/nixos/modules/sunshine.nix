# Sunshine module: Game streaming server (Moonlight compatible)
# GPU: NVIDIA RTX 5060 Ti passed through with x-vga=1 (Proxmox: qm set 401 --hostpci0 0000:01:00,pcie=1,x-vga=1)
{ config, lib, pkgs, pkgsUnstable, ... }:

{
  # Use sunshine from nixpkgs-unstable — it includes autoAddDriverRunpath which
  # bakes /run/opengl-driver/lib into the binary RPATH at build time, enabling
  # NVENC hardware encoding. LD_LIBRARY_PATH doesn't work for setcap binaries.
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;  # Required for KMS display capture
    package = pkgsUnstable.sunshine;
  };



  # udev rules for virtual input (mouse/keyboard injection)
  # /dev/uinput is owned by group "uinput" — must use that group, not "input"
  # ID_INPUT_KEYBOARD=1 tells libinput to treat sunshine's virtual keyboard as real,
  # preventing it from being silently disabled (libinput Send Events Mode = 0).
  #
  # libvirtualhid Mouse (Absolute) and Touchscreen are always created by Sunshine v2026.914+
  # for macOS Moonlight clients. They fight the relative mouse causing cursor desync.
  # ENV{LIBINPUT_IGNORE_DEVICE}="1" tells libinput to ignore them at the kernel level
  # so they never register as active X11 pointer devices — works on every reconnect,
  # independent of global_prep_cmd which only fires on first session after idle.
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    SUBSYSTEM=="input", ATTRS{name}=="Keyboard passthrough", ENV{ID_INPUT_KEYBOARD}="1", ENV{LIBINPUT_DEVICE_GROUP}="sunshine"
    SUBSYSTEM=="input", ATTRS{name}=="libvirtualhid Mouse (Absolute)", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    SUBSYSTEM=="input", ATTRS{name}=="libvirtualhid Touchscreen", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  # Load uinput kernel module at boot
  boot.kernelModules = [ "uinput" ];

  # uinput group for /dev/uinput access (sunshine virtual keyboard/mouse)
  users.groups.uinput = {};

  # Add moonblade to both input and uinput groups
  users.users.moonblade.extraGroups = [ "input" "uinput" "video" ];

  # Persist Sunshine config across NixOS rebuilds
  # capture = x11: NVIDIA proprietary Xorg bypasses KMS so DRM planes are always null.
  # X11 capture works correctly. With the unstable sunshine package (autoAddDriverRunpath),
  # nvenc should now work with x11 capture since libcuda.so.1 is in the binary RPATH.
  environment.etc."sunshine/sunshine.conf".text = ''
    min_bitrate = 20000
    fps = 60
    qp = 20
    adapter_name = NVIDIA GeForce RTX 5060 Ti
    capture = x11
    encoder = nvenc
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
    # Disable Sunshine's own software key repeat — let X11 handle it.
    # Sunshine's repeat fires independently and can get stuck if key-up is
    # dropped on a network hiccup, causing infinite key repeat.
    key_repeat_delay = -1
    # Disable VMware VMMouse devices on stream start — they compete with
    # Sunshine's Mouse passthrough and cause mouse desync. Re-enable on end.
    # Uses scripts in ~/.local/bin because xinput has two devices with the
    # same name and prep-cmd doesn't run through a shell (no env vars).
    global_prep_cmd = [{"do":"/home/moonblade/.local/bin/sunshine-mice-disable","undo":"/home/moonblade/.local/bin/sunshine-mice-enable"}]
  '';

  # Symlink config into place on activation
  system.activationScripts.sunshineConfig = ''
    mkdir -p /home/moonblade/.config/sunshine
    if [ ! -f /home/moonblade/.config/sunshine/sunshine.conf ]; then
      cp /etc/sunshine/sunshine.conf /home/moonblade/.config/sunshine/sunshine.conf
      chown moonblade:users /home/moonblade/.config/sunshine/sunshine.conf
    fi
  '';

  # Helper scripts to disable/enable VMware VMMouse devices around Sunshine sessions.
  # Needed because: (1) two devices share the same name so we find by ID dynamically,
  # and (2) prep-cmd doesn't run through a shell so DISPLAY=:0 can't be set inline.
  home-manager.users.moonblade.home.stateVersion = "26.05";
  home-manager.users.moonblade.home.file = {
    ".local/bin/sunshine-mice-disable" = {
      executable = true;
      force = true;
      text = ''
        #!/run/current-system/sw/bin/sh
        export DISPLAY=:0
        # Disable Proxmox-emulated VMware mice — they compete with Sunshine's relative mouse.
        # libvirtualhid Absolute mouse and Touchscreen are handled by udev (always ignored).
        xinput list | grep 'VMware VMMouse' | grep -o 'id=[0-9]*' | cut -d= -f2 | while read id; do
          xinput disable $id
        done
      '';
    };
    ".local/bin/sunshine-mice-enable" = {
      executable = true;
      force = true;
      text = ''
        #!/run/current-system/sw/bin/sh
        export DISPLAY=:0
        # Re-enable VMware mice on stream end (for local use).
        xinput list | grep 'VMware VMMouse' | grep -o 'id=[0-9]*' | cut -d= -f2 | while read id; do
          xinput enable $id
        done
      '';
    };
  };
}
