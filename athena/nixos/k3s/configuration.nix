{ config, pkgs, modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    nixpkgs.config.allowUnfree = true;

    # Enable QEMU Guest for Proxmox
    services.qemuGuest.enable = lib.mkDefault true;

    # Use the boot drive for grub
    boot.loader.grub.enable = lib.mkDefault true;
    boot.loader.grub.devices = [ "nodev" ];

    boot.growPartition = lib.mkDefault true;

    # Don't ask for passwords
    security.sudo.wheelNeedsPassword = false;
    programs.ssh.startAgent = true;

    # Default filesystem
    fileSystems."/" = lib.mkDefault {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    fileSystems."/mnt/external" = {
      device = "UUID=ffbf8741-5445-4e47-bb48-1851978346e9"; # Replace with the actual UUID of /dev/vdb
      fsType = "ext4";
      options = [ "nofail" "x-systemd.device-timeout=0" ];
    };

    users.groups.media = {
      gid = 1001;
    };

    time.timeZone = "Asia/Kolkata";

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

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
    ];
    users.users.root.initialPassword = "password";
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
      };
    };

    networking = {
      nameservers = [ 
       "8.8.8.8"
       "2001:4860:4860::8888"
      ];
      useNetworkd = true;
      useHostResolvConf = false;
      dhcpcd.IPv6rs = true; # Enable getting public IPv6 from router
      firewall.enable = false;
      interfaces.ens18 = {
        ipv4.addresses = [
          {
            address = "192.168.1.150";  # Static IP
            prefixLength = 24;          # Subnet mask
          }
        ];
      };
      defaultGateway = {
        address = "192.168.1.1";       # Default gateway IP address
        interface = "ens18";           # Interface associated with the default gateway
      };
    };

    services.resolved = {
      enable = true;
      fallbackDns = [ "8.8.8.8" ];
    };

    environment.systemPackages = with pkgs; [
      openiscsi
      curl
      gitMinimal
      nfs-utils
      vim
    ];

    system.activationScripts = { setupIscsi.text =
      # Longhorn expects these binaries in PATH
      ''
      ln -sf /run/current-system/sw/bin/iscsiadm /usr/bin/iscsiadm
      ln -sf /run/current-system/sw/bin/fstrim /usr/bin/fstrim
      ln -sf /run/wrappers/bin/mount /usr/bin/mount
      '';
    };

    boot.kernel.sysctl = {
      "fs.inotify.max_user_instances" = 1024;

      # https://www.blackmoreops.com/2014/09/22/linux-kernel-panic-issue-fix-hung_task_timeout_secs-blocked-120-seconds-problem/
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;
    };
    boot.kernelModules = [
      "ip6_tables"
      "ip6table_mangle"
      "ip6table_raw"
      "ip6table_filter"
    ];

    services.openiscsi = {
      enable = true;
      name = "${config.networking.hostName}-initiatorhost";
    };

    boot.supportedFilesystems = [ "nfs" "ext4" ];

    services.rpcbind.enable = true;

    system.stateVersion = lib.mkDefault "24.05";
  };
}
