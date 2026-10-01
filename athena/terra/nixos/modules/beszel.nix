# Beszel agent module: Server monitoring
{ config, pkgs, lib, ... }:

let
  beszelVersion = "0.18.7";
in
{
  # Beszel agent systemd service
  systemd.services.beszel-agent = {
    description = "Beszel Monitoring Agent";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    path = [ pkgs.curl pkgs.gnutar pkgs.gzip ];
    
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      StateDirectory = "beszel-agent";
      WorkingDirectory = "/var/lib/beszel-agent";
      # Load KEY from environment file
      EnvironmentFile = "/var/lib/beszel-agent/beszel.env";
    };
    
    environment = {
      PORT = "45876";
    };
    
    script = ''
      AGENT_PATH="/var/lib/beszel-agent/beszel-agent"
      VERSION="${beszelVersion}"
      
      # Check if KEY is set
      if [ -z "$KEY" ]; then
        echo "ERROR: KEY not set. Create /var/lib/beszel-agent/beszel.env with:"
        echo "KEY=ssh-ed25519 AAAA..."
        exit 1
      fi
      
      # Download if not exists or version mismatch
      if [ ! -f "$AGENT_PATH" ] || [ "$($AGENT_PATH --version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || echo "")" != "$VERSION" ]; then
        echo "Downloading beszel-agent v$VERSION..."
        curl -sL "https://github.com/henrygd/beszel/releases/download/v$VERSION/beszel-agent_linux_amd64.tar.gz" | tar -xz -C /var/lib/beszel-agent
        chmod +x "$AGENT_PATH"
      fi
      
      exec "$AGENT_PATH"
    '';
  };
  
  # Open firewall port for Beszel agent
  networking.firewall.allowedTCPPorts = [ 45876 ];
}
