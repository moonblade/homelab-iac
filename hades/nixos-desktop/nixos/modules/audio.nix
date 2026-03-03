# Audio module: PulseAudio for xrdp compatibility
# NOTE: xrdp audio ONLY works with PulseAudio, NOT PipeWire
{ config, lib, pkgs, ... }:

{
  # PulseAudio - required for xrdp audio support
  services.pulseaudio = {
    enable = true;
    # Enable extra modules for better compatibility
    package = pkgs.pulseaudioFull;
  };
  
  # IMPORTANT: Explicitly disable PipeWire to avoid conflicts
  # xrdp audio does NOT work with PipeWire
  services.pipewire.enable = false;

  # Audio control packages
  environment.systemPackages = with pkgs; [
    pavucontrol       # PulseAudio volume control GUI
    pamixer           # Command-line mixer
    playerctl         # MPRIS media player controller
  ];

  # Allow users in audio group to use audio
  users.extraGroups.audio = {};
}
