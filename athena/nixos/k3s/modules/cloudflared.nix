{ config, lib, pkgs, ... }: {

  services.cloudflared = {
    enable = true;
    tunnels = {
      "46b0a967-3b0f-493a-88e7-6f1cc9f8852b" = {
        credentialsFile = "/etc/nixos/k3s/secrets/46b0a967-3b0f-493a-88e7-6f1cc9f8852b.json";
        default = "http_status:404";
        ingress = {
          "siriusk8s.moonblade.work" = {
            service = "https://127.0.0.1:6443";
          };
          "siriusssh.moonblade.work" = {
            service = "ssh://127.0.0.1:22";
          };
          "*.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "moonblade.work" = {
            service = "http://192.168.1.200";
          };
        };
      };
    };
  };

}
