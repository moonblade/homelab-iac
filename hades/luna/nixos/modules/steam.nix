# Steam module: Gaming via Steam with NAS game library
# Game library stored on TrueNAS at /mnt/nas-games (NFS, auto-mounted)
# Uses dedicated NFS share with moonblade (uid=1000) mapping — separate from /mnt/nas
# to avoid symlink loops with the parent /mnt/nas automount.
{ config, lib, pkgs, ... }:

{
  # Enable Steam with NVIDIA support and Proton compatibility
  programs.steam = {
    enable = true;
    # Open firewall ports for Steam Remote Play and in-home streaming
    remotePlay.openFirewall = true;
    # Allow Steam to use Proton for Windows games
    extraCompatPackages = with pkgs; [
      proton-ge-bin  # GE-Proton: community Proton with better game compatibility
    ];
  };

  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Proton/Wine tools
    winetricks         # Install Windows runtime libraries for Wine/Proton
    protontricks       # Apply winetricks to Steam Proton prefixes

    # Performance tools
    mangohud           # In-game performance overlay (FPS, GPU, CPU usage)
    gamemode           # Feral's gamemode: optimises CPU/GPU for gaming

    # Controller support
    gamepad-tool       # GUI for gamepad configuration
    linuxConsoleTools  # jstest and other joystick utilities

    # Utilities
    steam-run          # Run non-Steam Linux binaries in Steam runtime environment
  ];

  # GameMode service (CPU governor + process priority optimisation)
  programs.gamemode.enable = true;

  # Ensure games NAS mount point exists
  # /mnt/nas-games is auto-mounted via NFS from TrueNAS (192.168.1.10:/mnt/primary/root/storage/games)
  system.activationScripts.steamGamesDir = ''
    mkdir -p /mnt/nas-games
  '';

  # Note: hardware.graphics and NVIDIA drivers are configured in ollama.nix.
  # enable32Bit is already set there — required for Steam/Proton 32-bit games.
}
