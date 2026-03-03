{ config, pkgs, modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    # Hostname
    networking.hostName = "luna";

    # Enable QEMU Guest for Proxmox
    services.qemuGuest.enable = lib.mkDefault true;

    # Use the boot drive for grub
    boot.loader.grub.enable = lib.mkDefault true;
    boot.loader.grub.devices = [ "nodev" ];
    boot.growPartition = lib.mkDefault true;

    # Don't ask for passwords for wheel group
    security.sudo.wheelNeedsPassword = false;
    programs.ssh.startAgent = true;

    # Default filesystem
    fileSystems."/" = lib.mkDefault {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    # Timezone
    time.timeZone = "Asia/Kolkata";

    # Locale
    i18n.defaultLocale = "en_US.UTF-8";

    # Nix settings
    nix = {
      settings = {
        trusted-users = [ "root" "@wheel" ];
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
    };

    # Root user SSH keys
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
    ];
    users.users.root.initialPassword = "nisham";

    # SSH server
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
      };
    };

    # Basic system packages
    environment.systemPackages = with pkgs; [
      curl
      gitMinimal
      vim
      wget
      htop
      unzip
      zip
    ];

    # System version
    system.stateVersion = lib.mkDefault "24.05";
  };
}
