# Polybar configuration for Luna VM
# Clean, modern status bar with icons
# No wireless, no battery (it's a VM), CPU/RAM as %, AM/PM time, separate date
{ config, lib, pkgs, ... }:

let
  # Catppuccin Mocha colors (matches alacritty theme)
  colors = {
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
    text = "#cdd6f4";
    subtext0 = "#a6adc8";
    subtext1 = "#bac2de";
    surface0 = "#313244";
    surface1 = "#45475a";
    surface2 = "#585b70";
    overlay0 = "#6c7086";
    blue = "#89b4fa";
    lavender = "#b4befe";
    sapphire = "#74c7ec";
    sky = "#89dceb";
    teal = "#94e2d5";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    peach = "#fab387";
    maroon = "#eba0ac";
    red = "#f38ba8";
    mauve = "#cba6f7";
    pink = "#f5c2e7";
    flamingo = "#f2cdcd";
    rosewater = "#f5e0dc";
  };

  polybarConfig = ''
    ;==========================================================
    ; Polybar config for Luna VM
    ; Catppuccin Mocha theme
    ;==========================================================

    [colors]
    background = ${colors.base}
    background-alt = ${colors.surface0}
    foreground = ${colors.text}
    primary = ${colors.blue}
    secondary = ${colors.lavender}
    alert = ${colors.red}
    disabled = ${colors.overlay0}
    green = ${colors.green}
    yellow = ${colors.yellow}
    cyan = ${colors.teal}
    pink = ${colors.pink}

    [bar/main]
    width = 100%
    height = 28pt
    radius = 0
    bottom = true

    background = ''${colors.background}
    foreground = ''${colors.foreground}

    line-size = 3pt

    border-size = 0pt
    border-color = #00000000

    padding-left = 1
    padding-right = 1

    module-margin = 1

    separator = |
    separator-foreground = ''${colors.disabled}

    font-0 = Inter:size=10;2
    font-1 = Font Awesome 6 Free Solid:size=10;2
    font-2 = Font Awesome 6 Brands:size=10;2
    font-3 = JetBrains Mono:size=10;2

    modules-left = i3
    modules-center = date time
    modules-right = ipv6 eth filesystem cpu memory

    cursor-click = pointer
    cursor-scroll = ns-resize

    enable-ipc = true

    tray-position = right
    tray-padding = 2

    ; wm-restack = i3
    ; override-redirect = true

    [module/i3]
    type = internal/i3
    pin-workspaces = false
    show-urgent = true
    strip-wsnumbers = true
    index-sort = true
    enable-click = true
    enable-scroll = true
    wrapping-scroll = false

    ; Show all 10 workspaces, format: [current/total] 1 2 3 ...
    format = <label-state> <label-mode>

    ; Focused workspace (current)
    label-focused =  %index%
    label-focused-background = ''${colors.background-alt}
    label-focused-foreground = ''${colors.primary}
    label-focused-underline = ''${colors.primary}
    label-focused-padding = 2

    ; Unfocused but has windows
    label-unfocused = %index%
    label-unfocused-foreground = ''${colors.foreground}
    label-unfocused-padding = 2

    ; Visible on other monitor (not applicable for single monitor)
    label-visible = %index%
    label-visible-background = ''${colors.background-alt}
    label-visible-padding = 2

    ; Urgent workspace
    label-urgent =  %index%
    label-urgent-background = ''${colors.alert}
    label-urgent-padding = 2

    ; Empty workspaces (no windows)
    label-empty = %index%
    label-empty-foreground = ''${colors.disabled}
    label-empty-padding = 2

    ; Mode indicator (resize, etc)
    label-mode = %mode%
    label-mode-background = ''${colors.alert}
    label-mode-padding = 2

    [module/ipv6]
    type = internal/network
    interface-type = wired
    interval = 5
    format-connected = <label-connected>
    format-disconnected = <label-disconnected>
    label-connected =  %local_ip6%
    label-connected-foreground = ''${colors.cyan}
    label-disconnected =  none
    label-disconnected-foreground = ''${colors.disabled}

    [module/eth]
    type = internal/network
    interface = ens18
    interval = 1

    format-connected = <label-connected>
    label-connected = ETH %local_ip%  %downspeed%  %upspeed%
    label-connected-foreground = ''${colors.green}

    format-disconnected = <label-disconnected>
    label-disconnected = ETH disconnected
    label-disconnected-foreground = ''${colors.disabled}

    [module/filesystem]
    type = internal/fs
    interval = 30

    mount-0 = /

    label-mounted = DISK %percentage_used%%
    label-mounted-foreground = ''${colors.yellow}

    label-unmounted = %mountpoint% not mounted
    label-unmounted-foreground = ''${colors.disabled}

    [module/cpu]
    type = internal/cpu
    interval = 2
    format-prefix = "CPU "
    format-prefix-foreground = ''${colors.primary}
    label = %percentage:2%%
    label-foreground = ''${colors.primary}

    [module/memory]
    type = internal/memory
    interval = 2
    format-prefix = "RAM "
    format-prefix-foreground = ''${colors.pink}
    label = %percentage_used:2%%
    label-foreground = ''${colors.pink}

    [module/date]
    type = internal/date
    interval = 60

    date = %a %b %d

    label =  %date%
    label-foreground = ''${colors.foreground}

    [module/time]
    type = internal/date
    interval = 5

    time = %I:%M %p

    label =  %time%
    label-foreground = ''${colors.secondary}

    [settings]
    screenchange-reload = true
    pseudo-transparency = true
  '';

  polybarPkg = pkgs.polybar.override {
    i3Support = true;
  };

  polybarLaunchScript = pkgs.writeShellScriptBin "polybar-launch" ''
    # Terminate already running bar instances
    ${polybarPkg}/bin/polybar-msg cmd quit 2>/dev/null || true

    # Wait until the processes have been shut down
    while ${pkgs.procps}/bin/pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

    # Launch polybar
    ${polybarPkg}/bin/polybar main 2>&1 | ${pkgs.coreutils}/bin/tee -a /tmp/polybar.log &

    echo "Polybar launched..."
  '';

in
{
  environment.systemPackages = [
    polybarPkg
    polybarLaunchScript
  ];

  # Deploy polybar config for moonblade user
  system.activationScripts.polybarConfig = ''
    mkdir -p /home/moonblade/.config/polybar
    cat > /home/moonblade/.config/polybar/config.ini << 'EOFPOLYBAR'
${polybarConfig}
EOFPOLYBAR
    chown -R moonblade:users /home/moonblade/.config/polybar
  '';
}
