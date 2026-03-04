# Browsers module: Firefox and Chrome
{ config, lib, pkgs, ... }:

{
  # Allow unfree packages (required for Chrome)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Firefox - primary browser
    firefox
    
    # Google Chrome - secondary browser
    google-chrome
  ];

  # Firefox policies (optional - customize as needed)
  programs.firefox = {
    enable = true;
    policies = {
      # Disable telemetry
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      
      # Enable tracking protection
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      
      # Don't check if Firefox is default browser
      DontCheckDefaultBrowser = true;
    };
  };
}
