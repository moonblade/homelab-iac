# Networking module: Static IP configuration
{ config, lib, pkgs, ... }:

{
  networking = {
    # DNS servers
    nameservers = [ 
      "8.8.8.8"
      "8.8.4.4"
    ];
    
    # Use systemd-networkd
    useNetworkd = true;
    useHostResolvConf = false;
    
    # Disable firewall for homelab (rely on network isolation)
    firewall.enable = false;
    
    # Static IP configuration
    # Interface name is typically ens18 for Proxmox VMs
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "192.168.1.199";  # Static IP (prime number)
          prefixLength = 24;          # /24 subnet
        }
      ];
    };
    
    # Default gateway
    defaultGateway = {
      address = "192.168.1.1";
      interface = "ens18";
    };
  };

  # DNS resolver
  services.resolved = {
    enable = true;
    # Use new settings format
    settings.Resolve.FallbackDNS = [ "8.8.8.8" "8.8.4.4" ];
  };

  # Network Manager for easy WiFi/VPN management (if needed)
  # Disabled by default since we're using static IP
  # networking.networkmanager.enable = true;
}
