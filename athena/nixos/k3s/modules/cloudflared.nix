{ config, lib, pkgs, ... }: {

  sops.secrets.cloudflared-creds = {
    needed = true;
    path = "/etc/nixos/k3s/secrets/cert.pem";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "0e312d9a-2cfc-4504-ad89-2f0e433b68d6" = {
        credentialsFile = "${config.sops.secrets.cloudflared-creds.path}";
        default = "http_status:404";
      };
    };
  }
}
