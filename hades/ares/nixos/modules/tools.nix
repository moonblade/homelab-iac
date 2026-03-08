# Tools module: CLI-focused tools for SSH-primary VM
# Simplified from Luna - no browsers, GUI file managers, or Flatpak
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
    
    # File management (CLI only)
    ranger            # Terminal file manager
    
    # Text editors
    neovim            # Modern vim
    
    # Image viewing/wallpapers
    feh               # Image viewer and wallpaper setter
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
    fzf               # Fuzzy finder
    
    # Development tools (for opencode/openclaw)
    nodejs_22         # Node.js LTS
    python3           # Python 3
    rustup            # Rust toolchain
    go                # Go language
    git               # Version control
    gh                # GitHub CLI
    lazygit           # Git TUI
    delta             # Better git diff
  ];

  # Deploy alacritty config
  system.activationScripts.alacrittyConfig = ''
    mkdir -p /home/moonblade/.config/alacritty
    cat > /home/moonblade/.config/alacritty/alacritty.toml << 'EOFALACRITTY'
${alacrittyConfig}
EOFALACRITTY
    chown -R moonblade:users /home/moonblade/.config/alacritty
  '';

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
