# i3status-rust configuration for Luna VM
# Modern status bar for i3 with fixed-width blocks
# No wireless, no battery (it's a VM), CPU/RAM as %, AM/PM time
{ config, lib, pkgs, ... }:

let
  i3statusRustBin = "${pkgs.i3status-rust}/bin/i3status-rs";
  
  # Catppuccin Mocha theme for i3status-rust
  # Block order: date, time (left side of status), then system info (right)
  i3statusConfig = ''
    [theme]
    theme = "ctp-mocha"

    [theme.overrides]
    idle_bg = "#1e1e2e"
    idle_fg = "#cdd6f4"
    info_bg = "#1e1e2e"
    info_fg = "#89b4fa"
    good_bg = "#1e1e2e"
    good_fg = "#a6e3a1"
    warning_bg = "#1e1e2e"
    warning_fg = "#f9e2af"
    critical_bg = "#1e1e2e"
    critical_fg = "#f38ba8"
    separator = " | "
    separator_bg = "auto"
    separator_fg = "#6c7086"

    [[block]]
    block = "time"
    format = " $timestamp.datetime(f:'%a %b %d') "
    interval = 60
    [block.theme_overrides]
    idle_fg = "#cdd6f4"

    [[block]]
    block = "time"
    format = " $timestamp.datetime(f:'%I:%M %p') "
    interval = 5
    [block.theme_overrides]
    idle_fg = "#b4befe"

    [[block]]
    block = "net"
    device = "ens18"
    format = " ↓$speed_down.eng(prefix:K,w:4,pad_with:' ') ↑$speed_up.eng(prefix:K,w:4,pad_with:' ') "
    interval = 2
    [block.theme_overrides]
    idle_fg = "#a6e3a1"

    [[block]]
    block = "disk_space"
    path = "/"
    format = " DISK $percentage.eng(w:3,pad_with:' ') "
    info_type = "used"
    alert_unit = "GB"
    interval = 30
    warning = 80.0
    alert = 90.0
    [block.theme_overrides]
    idle_fg = "#f9e2af"

    [[block]]
    block = "cpu"
    format = " CPU $utilization.eng(w:3,pad_with:' ') "
    interval = 2
    [block.theme_overrides]
    idle_fg = "#89b4fa"

    [[block]]
    block = "memory"
    format = " RAM $mem_used_percents.eng(w:3,pad_with:' ') "
    interval = 2
    [block.theme_overrides]
    idle_fg = "#f5c2e7"
  '';

in
{
  environment.systemPackages = [
    pkgs.i3status-rust
    # Wrapper script so i3 can find i3status-rs
    (pkgs.writeShellScriptBin "i3status-rs-wrapper" ''
      exec ${i3statusRustBin} ~/.config/i3status-rust/config.toml
    '')
  ];

  # Deploy i3status-rust config for moonblade user
  system.activationScripts.i3statusRustConfig = ''
    mkdir -p /home/moonblade/.config/i3status-rust
    cat > /home/moonblade/.config/i3status-rust/config.toml << 'EOFI3STATUS'
${i3statusConfig}
EOFI3STATUS
    chown -R moonblade:users /home/moonblade/.config/i3status-rust
  '';
}
