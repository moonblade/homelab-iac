# Browsers module: Firefox and Chrome
{ config, lib, pkgs, ... }:

let
  # Chrome doesn't follow Xft.dpi; force a device scale factor so UI isn't
  # tiny at 1920x1200 (matches the 108 DPI set for other apps, 108/96=1.125)
  google-chrome-scaled = pkgs.google-chrome.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      sed -i 's|\(google-chrome-stable\)\( --incognito\)\?\( %U\)\?$|\1 --force-device-scale-factor=1.125\2\3|' \
        $out/share/applications/google-chrome.desktop
    '';
  });
in
{
  # Allow unfree packages (required for Chrome)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Firefox - primary browser
    firefox
    
    # Google Chrome - secondary browser (scaled for DPI, see above)
    google-chrome-scaled
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
