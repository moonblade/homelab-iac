{ config, lib, pkgs, ... }: {
  # Enable Docker service
  virtualisation.docker.enable = true;

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--docker"  # Enable Docker runtime
      "--disable traefik"
      "--disable servicelb"
      "--disable metrics-server"
      "--disable-cloud-controller"
      "--kube-proxy-arg proxy-mode=ipvs"
      "--cluster-cidr=10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
      "--disable-network-policy"
      "--node-ip=192.168.1.150"
      "--tls-san sirius.moonblade.work"
      "--tls-san siriusk8s.moonblade.work"
      "--disable local-storage"
      "--disable-helm-controller"
      "--write-kubeconfig /root/.kube/config"
      "--flannel-backend=host-gw"
      "--write-kubeconfig-mode 644"
      "--node-name=sirius"
    ];
  };
}
