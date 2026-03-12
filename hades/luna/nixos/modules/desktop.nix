# Desktop module: X11 + i3 window manager
{ config, lib, pkgs, ... }:

{
  # macOS-style cursor theme
  environment.sessionVariables = {
    XCURSOR_THEME = "macOS";
    XCURSOR_SIZE = "24";
  };
  # Enable X11
  services.xserver = {
    enable = true;
    
    # Virtual display resolution for headless streaming
    # Required for Sunshine/Moonlight - xrdp negotiates dynamically but Sunshine captures existing display
    # 1680x1050 chosen for comfortable scaling on MacBook displays
    xrandrHeads = [
      {
        output = "Virtual-1";
        primary = true;
        monitorConfig = ''
          Option "PreferredMode" "1680x1050"
        '';
      }
    ];
    
    # Fallback resolution if virtual display not detected
    resolutions = [
      { x = 1680; y = 1050; }
      { x = 1920; y = 1080; }
      { x = 1440; y = 900; }
    ];
    
    # Display manager - LightDM for graphical login
    displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        enable = true;
        theme.name = "Adwaita-dark";
        cursorTheme = {
          name = "macOS";
          package = pkgs.apple-cursor;
          size = 24;
        };
      };
    };
    
    # i3 window manager
    # Note: i3-gaps was merged into i3 upstream
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
      extraPackages = with pkgs; [
        i3status       # Status bar
        i3lock         # Screen locker
        i3blocks       # Alternative status bar
      ];
    };
    
    # Keyboard layout
    xkb = {
      layout = "us";
      options = "caps:escape"; # Caps Lock as Escape (helpful for vim users)
    };
  };

  # Display manager settings (top-level in newer NixOS)
  services.displayManager = {
    defaultSession = "none+i3";
    
    # Auto-login for Sunshine streaming (no login screen)
    autoLogin = {
      enable = true;
      user = "moonblade";
    };
  };

  # Set cursor on X session start
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
  '';

  # Essential X11 packages (xorg.* renamed to top-level)
  environment.systemPackages = with pkgs; [
    xrandr            # Display configuration
    xinit             # X initialization
    xauth             # X authentication
    arandr            # GUI for xrandr
    autorandr         # Automatic display configuration
    picom             # Compositor for transparency/shadows
    nitrogen          # Wallpaper setter (alternative to feh)
    lxappearance      # GTK theme configuration
    apple-cursor      # macOS-style cursor theme
  ];

  # GTK cursor theme configuration
  environment.etc = {
    "gtk-2.0/gtkrc".text = ''
      gtk-cursor-theme-name="macOS"
      gtk-cursor-theme-size=24
    '';
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-cursor-theme-name=macOS
      gtk-cursor-theme-size=24
    '';
  };

  # Fonts - macOS-like defaults (Inter = open-source SF Pro alternative)
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      inter                 # SF Pro alternative (system UI font)
      roboto                # Clean sans-serif
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji  # renamed from noto-fonts-emoji
      jetbrains-mono        # Monospace
      fira-code
      font-awesome          # For i3status icons
      liberation_ttf
      source-sans           # Adobe Source Sans (clean UI font)
      source-serif          # Adobe Source Serif
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Source Serif 4" "Noto Serif" ];
        sansSerif = [ "Inter" "Roboto" ];
        monospace = [ "JetBrains Mono" "Fira Code" ];
      };
      # Better font rendering (macOS-like)
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };
  };

  # XDG desktop integration
  xdg = {
    autostart.enable = true;
    menus.enable = true;
    mime.enable = true;
    icons.enable = true;
  };

  # Enable dbus for desktop applications
  services.dbus.enable = true;

  # Power management
  services.upower.enable = true;

  # Thumbnail generation for file managers
  services.tumbler.enable = true;
}
