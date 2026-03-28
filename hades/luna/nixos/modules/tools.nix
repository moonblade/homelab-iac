# Tools module: Essential desktop tools
{ config, lib, pkgs, ... }:

let
  alacrittyConfig = ''
    [window]
    opacity = 0.95
    padding = { x = 5, y = 5 }

    [font]
    size = 11.0

    [font.normal]
    family = "JetBrains Mono"
    style = "Regular"

    [font.bold]
    family = "JetBrains Mono"
    style = "Bold"

    # Dark theme (One Dark inspired)
    [colors.primary]
    background = "#1e1e2e"
    foreground = "#cdd6f4"

    [colors.normal]
    black   = "#45475a"
    red     = "#f38ba8"
    green   = "#a6e3a1"
    yellow  = "#f9e2af"
    blue    = "#89b4fa"
    magenta = "#f5c2e7"
    cyan    = "#94e2d5"
    white   = "#bac2de"

    [colors.bright]
    black   = "#585b70"
    red     = "#f38ba8"
    green   = "#a6e3a1"
    yellow  = "#f9e2af"
    blue    = "#89b4fa"
    magenta = "#f5c2e7"
    cyan    = "#94e2d5"
    white   = "#a6adc8"
  '';
in
{
  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty         # Modern GPU-accelerated terminal
    xterm             # Fallback terminal
    
    # Fonts for terminal
    jetbrains-mono    # JetBrains Mono for alacritty
    
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
    
    # AI coding assistant
    opencode          # Terminal-based AI coding agent
    bun               # JavaScript runtime for oh-my-opencode (run: bunx oh-my-opencode install)
    
    # Build tools
    gnumake           # GNU Make
    
    # Media control
    playerctl         # MPRIS media player controller (controls Chrome, Firefox, etc.)
    xdotool           # X11 automation - send keystrokes to apps (for Stremio which lacks MPRIS)
    
    # Media - Stremio installed via Flatpak (flatpak install flathub com.stremio.Stremio)
    # Sunshine also requires insecure qtwebengine - install via Flatpak if needed
  ];

  # Deploy alacritty config
  system.activationScripts.alacrittyConfig = ''
    mkdir -p /home/moonblade/.config/alacritty
    cat > /home/moonblade/.config/alacritty/alacritty.toml << 'EOFALACRITTY'
${alacrittyConfig}
EOFALACRITTY
    chown -R moonblade:users /home/moonblade/.config/alacritty
  '';

  # Enable Flatpak for sandboxed apps (Stremio)
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # Add Flathub repo on first boot: flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

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
