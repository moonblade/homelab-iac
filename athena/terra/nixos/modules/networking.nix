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
    # Interface is ens18 - no GPU passthrough on Athena, standard i440fx/Q35 default NIC naming
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "192.168.1.200";  # Static IP
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
}
