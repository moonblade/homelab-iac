# Nginx Proxy Manager module for Luna
# Runs NPM in Docker (host networking) to proxy ollama.moonblade.work → localhost:11434
# SSL via Let's Encrypt + Cloudflare DNS challenge
{ config, pkgs, lib, ... }:

{
  # Enable Docker daemon
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # NPM systemd service managed via docker compose
  systemd.services.nginx-proxy-manager = {
    description = "Nginx Proxy Manager";
    after = [ "docker.service" "network-online.target" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
      WorkingDirectory = "/root/workspace/nginx-proxy-manager";
      ExecStart = "${pkgs.docker}/bin/docker compose up";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
    };

    preStart = ''
      mkdir -p /root/workspace/nginx-proxy-manager
    '';
  };

  # docker compose is a plugin; expose the compose binary directly as well
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    sqlite  # for cert DB manipulation
  ];
}
