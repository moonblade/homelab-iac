# Audio module: PipeWire (replaces PulseAudio)
# PipeWire provides PulseAudio compatibility via pipewire-pulse,
# better latency, and works correctly with Sunshine/Moonlight streaming.
{ config, lib, pkgs, ... }:

{
  # Disable PulseAudio — PipeWire replaces it
  services.pulseaudio.enable = false;

  # PipeWire with full compatibility layers
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;   # PulseAudio compatibility (pavucontrol etc. still work)
    jack.enable = false;
  };

  # Real-time scheduling for PipeWire (low-latency audio)
  security.rtkit.enable = true;

  # Audio control packages
  environment.systemPackages = with pkgs; [
    pavucontrol       # PulseAudio volume control GUI (works via pipewire-pulse)
    pamixer           # Command-line mixer
    playerctl         # MPRIS media player controller
  ];

  # Allow users in audio group to use audio
  users.extraGroups.audio = {};
}
