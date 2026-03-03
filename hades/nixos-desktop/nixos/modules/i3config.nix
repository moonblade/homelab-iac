# i3 configuration module with vim-style keybindings
{ config, lib, pkgs, ... }:

let
  i3Config = ''
    # i3 config file (v4)
    # Vim-style keybindings (hjkl)

    set $mod Mod4

    # Font
    font pango:Inter 10

    # Vim-style navigation: h=left, j=down, k=up, l=right
    set $left h
    set $down j
    set $up k
    set $right l

    # Start XDG autostart
    exec --no-startup-id dex --autostart --environment i3

    # Screen lock
    exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork

    # NetworkManager applet
    exec --no-startup-id nm-applet

    # Volume controls
    set $refresh_i3status killall -SIGUSR1 i3status
    bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
    bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
    bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
    bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status

    # Mouse+$mod to drag floating windows
    floating_modifier $mod
    tiling_drag modifier titlebar

    # Terminal
    bindsym $mod+Return exec alacritty

    # Kill focused window
    bindsym $mod+Shift+q kill

    # Application launcher (rofi)
    bindsym $mod+d exec --no-startup-id rofi -show drun

    # Change focus (vim-style)
    bindsym $mod+$left focus left
    bindsym $mod+$down focus down
    bindsym $mod+$up focus up
    bindsym $mod+$right focus right

    # Arrow keys also work
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # Move focused window (vim-style)
    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$down move down
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$right move right

    # Arrow keys for moving
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    # Split orientation
    bindsym $mod+b split h
    bindsym $mod+v split v

    # Fullscreen
    bindsym $mod+f fullscreen toggle

    # Layout (stacked, tabbed, toggle split)
    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split

    # Toggle floating
    bindsym $mod+Shift+space floating toggle

    # Focus floating/tiling
    bindsym $mod+space focus mode_toggle

    # Focus parent
    bindsym $mod+a focus parent

    # Scratchpad
    bindsym $mod+Shift+minus move scratchpad
    bindsym $mod+minus scratchpad show

    # Workspaces
    set $ws1 "1"
    set $ws2 "2"
    set $ws3 "3"
    set $ws4 "4"
    set $ws5 "5"
    set $ws6 "6"
    set $ws7 "7"
    set $ws8 "8"
    set $ws9 "9"
    set $ws10 "10"

    # Switch to workspace
    bindsym $mod+1 workspace number $ws1
    bindsym $mod+2 workspace number $ws2
    bindsym $mod+3 workspace number $ws3
    bindsym $mod+4 workspace number $ws4
    bindsym $mod+5 workspace number $ws5
    bindsym $mod+6 workspace number $ws6
    bindsym $mod+7 workspace number $ws7
    bindsym $mod+8 workspace number $ws8
    bindsym $mod+9 workspace number $ws9
    bindsym $mod+0 workspace number $ws10

    # Move container to workspace
    bindsym $mod+Shift+1 move container to workspace number $ws1
    bindsym $mod+Shift+2 move container to workspace number $ws2
    bindsym $mod+Shift+3 move container to workspace number $ws3
    bindsym $mod+Shift+4 move container to workspace number $ws4
    bindsym $mod+Shift+5 move container to workspace number $ws5
    bindsym $mod+Shift+6 move container to workspace number $ws6
    bindsym $mod+Shift+7 move container to workspace number $ws7
    bindsym $mod+Shift+8 move container to workspace number $ws8
    bindsym $mod+Shift+9 move container to workspace number $ws9
    bindsym $mod+Shift+0 move container to workspace number $ws10

    # Reload/restart i3
    bindsym $mod+Shift+c reload
    bindsym $mod+Shift+r restart
    bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'"

    # Resize mode (also vim-style)
    mode "resize" {
        bindsym $left resize shrink width 10 px or 10 ppt
        bindsym $down resize grow height 10 px or 10 ppt
        bindsym $up resize shrink height 10 px or 10 ppt
        bindsym $right resize grow width 10 px or 10 ppt

        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
        bindsym Right resize grow width 10 px or 10 ppt

        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
    }

    bindsym $mod+r mode "resize"

    # Status bar
    bar {
        status_command i3status
        font pango:Inter, Font Awesome 6 Free 10
        position bottom
    }

    # Gaps (optional, for aesthetics)
    gaps inner 5
    gaps outer 2

    # Window borders
    default_border pixel 2
    default_floating_border pixel 2

    # Colors (subtle, macOS-ish)
    client.focused          #4c7899 #285577 #ffffff #2e9ef4 #285577
    client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
    client.unfocused        #333333 #222222 #888888 #292d2e #222222
  '';
in
{
  # Deploy i3 config for moonblade user
  environment.etc."skel/.config/i3/config".text = i3Config;
  
  # Also place it directly in moonblade's home (managed by NixOS)
  system.activationScripts.i3config = ''
    mkdir -p /home/moonblade/.config/i3
    cat > /home/moonblade/.config/i3/config << 'EOFI3'
${i3Config}
EOFI3
    chown -R moonblade:users /home/moonblade/.config
  '';
}
