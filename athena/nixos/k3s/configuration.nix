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
      device = "192.168.1.128:/mnt/external";
      fsType = "nfs";
      options = [ "defaults" "nofail" "x-systemd.device-timeout=0" ];
    };

    fileSystems."/mnt/secondary" = {
      device = "192.168.1.128:/mnt/secondary";
      fsType = "nfs";
      options = [ "defaults" "nofail" "x-systemd.device-timeout=0" ];
    };

    # fileSystems."/mnt/external" = {
    #   device = "UUID=ffbf8741-5445-4e47-bb48-1851978346e9";
    #   fsType = "ext4";
    #   options = [ "nofail" "x-systemd.device-timeout=0" ];
    # };

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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBZYUtAZtLS8Ug7qvOpNIp1pZJetxMnaHnrw/i5S3EjBN0Hb+HRTAWSUEqH/NGZt9fTWdjAAglEE50nFfp3jfDZbpTgInW/ZHTypm9KyH1NqJ2Y9yzC4tBGNZ2JsGn/YrQ8gjWwuQdqySKByWbwi2g5dODVvxXMK5Sbim2PuEJId51IabAk8ijRpZZcbWTuU8CsuLvblmdY+w8nOOn898XFpQ17ScQXJGnuvDCYR2mqJNAS/XQb1JkbnIsAUiCXDQ+GRZovAOakQ7mATbQP9HHPCicjL51h5akDW53StiEqGrN8DmLptum/2D6bG1hMnA4XsT77K4rjfx/nqkpanYUis/e/9W2OvxJFWWX1c1WqzhyPgIjJdwV1Qj6nZro20OTMI7HH9F0B4XgqJGbS4O8SDPTiQ9gu1ldkuj2GSvWDd0Iq3MYyc+PIjKBHsl6gyxk9a7iIXSwghsJSYZgKSiU7sb8nOx6QGDkHE8t1IpEZSzwgTm2UR5JvrHXyZEm927y88SKU7VXDNmL1NV9uGZxucxSpHGGjEviu2OdklXVgA4rVPVG9aI01YoKDeRV0SpiEgsX8lss4F5yzlwP4i9oMm/X1qKEYq6Td6D9yXsiRZcKVpYJEsvFQiLHnb4PMNhQrnTY9yTKbYoGSEjGWzZN6WsBnWPyI6SCRDz0XAubgQ== root@thinkcenter"
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
    systemd.services.resolved.serviceConfig = {
      DNS = [
        "8.8.8.8"
      ];
      FallbackDNS = [
        "8.8.4.4"
      ];
    };

    environment.systemPackages = with pkgs; [
      kubie
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

    services.openiscsi = {
      enable = true;
      name = "${config.networking.hostName}-initiatorhost";
    };

    boot.supportedFilesystems = [ "nfs" "ext4" ];

    services.rpcbind.enable = true;

    system.stateVersion = lib.mkDefault "24.05";
  };
}
