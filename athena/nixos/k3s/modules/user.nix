{ config, lib, pkgs, ... }: {

  users.extraUsers.operator = {
    isNormalUser = true;
    home = "/root";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
    ];
  };

  users.extraUsers.media = {
    isNormalUser = true;
    home = "/home/media";
    description = "Media user for Transmission";
    group = "media";
    shell = "/bin/sh";
    uid = 1001;
  };

  users.motd = with config; ''
    Welcome to ${networking.hostName}

    - This server is managed by NixOS
    - Admin: moonblade

    OS:      NixOS ${system.nixos.release} (${system.nixos.codeName})
    Version: ${system.nixos.version}
    Kernel:  ${boot.kernelPackages.kernel.version}
  '';

}
