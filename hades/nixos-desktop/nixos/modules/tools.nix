# Tools module: Essential desktop tools
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty         # Modern GPU-accelerated terminal
    xterm             # Fallback terminal
    
    # Application launchers
    dmenu             # Simple and fast launcher
    rofi              # Feature-rich launcher with themes
    
    # File management
    pcmanfm           # Lightweight file manager
    thunar            # Feature-rich file manager (moved from xfce.thunar)
    ranger            # Terminal file manager
    
    # Text editors
    neovim            # Modern vim
    vscode            # VS Code (unfree)
    
    # Image viewing/wallpapers
    feh               # Image viewer and wallpaper setter
    flameshot         # Screenshot tool
    scrot             # Simple screenshot utility
    
    # Clipboard
    xclip             # Command-line clipboard
    xsel              # Another clipboard tool
    
    # System monitoring
    btop              # Beautiful resource monitor
    neofetch          # System info display
    
    # Notifications
    dunst             # Notification daemon
    libnotify         # Send notifications from command line
    
    # Archive tools
    p7zip             # 7zip support
    unrar             # RAR extraction
    
    # Misc utilities
    tree              # Directory tree view
    ripgrep           # Fast grep alternative
    fd                # Fast find alternative
    bat               # Cat with syntax highlighting
    jq                # JSON processor
    
    # Network tools
    networkmanagerapplet  # Network tray icon (if using NetworkManager)
    
    # Media
    stremio               # Media center
  ];

  # Enable tmux
  programs.tmux.enable = true;

  # Enable neovim as default editor
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
