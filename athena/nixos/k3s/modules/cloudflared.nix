{ config, lib, pkgs, ... }: {

  services.cloudflared = {
    enable = true;
    tunnels = {
      "46b0a967-3b0f-493a-88e7-6f1cc9f8852b" = {
        credentialsFile = "/etc/nixos/k3s/secrets/46b0a967-3b0f-493a-88e7-6f1cc9f8852b.json";
        default = "http://192.168.1.201";
        ingress = {
          "siriusk8s.moonblade.work" = {
            service = "https://127.0.0.1:6443";
          };
          "siriusssh.moonblade.work" = {
            service = "ssh://127.0.0.1:22";
          };
          # Still on ingress-nginx (192.168.1.200) - migrate these
          "audiobook.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "audiobooksearch.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "browse.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "ddsearch.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "expense.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "homer.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "jackett.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "jellyfin.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "login.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "n8n.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "transmission.moonblade.work" = {
            service = "http://192.168.1.200";
          };
          "weave.moonblade.work" = {
            service = "http://192.168.1.200";
          };
        };
      };
    };
  };

}
