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
    # Interface is enp6s18 on Q35 machine type (was ens18 on i440fx/pc)
    # Q35 places the VirtIO NIC on a different PCI bus, changing the udev name
    interfaces.enp6s18 = {
      ipv4.addresses = [
        {
          address = "192.168.1.199";  # Static IP
          prefixLength = 24;          # /24 subnet
        }
      ];
    };
    
    # Default gateway
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp6s18";
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
