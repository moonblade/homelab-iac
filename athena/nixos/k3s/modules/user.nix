{ config, lib, pkgs, ... }:

let
  vars = import ../variables.nix;
in
{

  users.extraUsers.operator = {
    isNormalUser = true;
    home = "/root";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      vars.sshPubKey
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
