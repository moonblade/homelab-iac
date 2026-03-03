# Tailscale module: VPN access
{ config, pkgs, ... }:

{
  environment.systemPackages = [ 
    pkgs.tailscale 
    pkgs.dnslookup
  ];

  # Kernel settings for Tailscale routing
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Tailscale service
  services.tailscale = {
    enable = true;
    # Don't use Tailscale DNS (use local DNS instead)
    extraSetFlags = [
      "--accept-dns=false"
    ];
    extraUpFlags = [
      "--accept-dns=false"
    ];
  };

  # Auto-connect service (checks status, manual auth required first time)
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";

    script = with pkgs; ''
      # Wait for tailscaled to settle
      sleep 2

      # Check if already authenticated
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ "$status" = "Running" ]; then
        exit 0
      fi

      # Manual authentication required on first boot
      # Run: sudo tailscale up
      echo "Tailscale not authenticated. Run 'sudo tailscale up' to authenticate."
    '';
  };
}
