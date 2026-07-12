# Steam module: Gaming via Steam with NAS game library
# Game library stored on TrueNAS at /mnt/nas/storage/games (NFS, auto-mounted)
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

  # Ensure games NAS directory exists and is accessible
  # /mnt/nas is auto-mounted via NFS from TrueNAS (192.168.1.10:/mnt/primary/root)
  # Game library path: /mnt/nas/storage/games
  system.activationScripts.steamGamesDir = ''
    mkdir -p /mnt/nas/storage/games
  '';

  # Note: hardware.graphics and NVIDIA drivers are configured in ollama.nix.
  # enable32Bit is already set there — required for Steam/Proton 32-bit games.
}
