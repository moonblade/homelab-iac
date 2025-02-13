{ config, lib, pkgs, ... }: {

  services.cloudflared = {
    enable = true;
    tunnels = {
      "46b0a967-3b0f-493a-88e7-6f1cc9f8852b" = {
        credentialsFile = "/etc/nixos/k3s/secrets/46b0a967-3b0f-493a-88e7-6f1cc9f8852b.json";
        default = "http_status:404";
        ingress = {
          "*.cf.moonblade.work" = {
            service = "http://192.168.1.200";
          };
        };
      };
    };
  };

}
