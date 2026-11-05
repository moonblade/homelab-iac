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

  # Certbot renewal: runs inside the NPM container daily, reloads nginx after.
  # cloudflare.ini lives in the persisted /data volume at /data/certbot/cloudflare.ini
  # (survives container recreates; written once by Makefile configure-proxy).
  systemd.services.npm-cert-renew = {
    description = "Renew Let's Encrypt certs inside Nginx Proxy Manager";
    after = [ "nginx-proxy-manager.service" ];
    requires = [ "nginx-proxy-manager.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "npm-cert-renew" ''
        CONTAINER=nginx-proxy-manager-app-1
        # Ensure plugin present (lost when image is upgraded/recreated)
        ${pkgs.docker}/bin/docker exec $CONTAINER pip install certbot-dns-cloudflare -q 2>/dev/null || true
        # Renew all certs; deploy-hook copies new cert to npm-1/ and reloads nginx
        ${pkgs.docker}/bin/docker exec $CONTAINER certbot renew \
          --quiet \
          --deploy-hook '
            BASE=/etc/letsencrypt
            cp $(readlink -f $BASE/live/ollama.moonblade.work/fullchain.pem) $BASE/live/npm-1/fullchain.pem
            cp $(readlink -f $BASE/live/ollama.moonblade.work/privkey.pem)   $BASE/live/npm-1/privkey.pem
            cp $(readlink -f $BASE/live/ollama.moonblade.work/cert.pem)      $BASE/live/npm-1/cert.pem
            cp $(readlink -f $BASE/live/ollama.moonblade.work/chain.pem)     $BASE/live/npm-1/chain.pem
            nginx -s reload
          ' 2>&1 | logger -t npm-cert-renew
      '';
    };
  };

  systemd.timers.npm-cert-renew = {
    description = "Daily Let's Encrypt cert renewal for NPM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };

  # docker compose is a plugin; expose the compose binary directly as well
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    sqlite  # for cert DB manipulation
  ];
}
