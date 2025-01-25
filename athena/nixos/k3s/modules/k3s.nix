{ config, lib, pkgs, ... }: {

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable traefik"
      "--disable servicelb"
      "--disable metrics-server"
      "--disable-cloud-controller"
      "--kube-proxy-arg proxy-mode=ipvs"
      "--cluster-cidr=10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
      "--snapshotter native"
      "--disable-network-policy"
      "--node-ip=192.168.1.150"
      "--disable local-storage"
      "--disable-helm-controller"
      "--write-kubeconfig /root/.kube/config"
      "--flannel-backend=host-gw"
      "--write-kubeconfig-mode 644"
      "--node-name=sirius"
    ];
  };

}
