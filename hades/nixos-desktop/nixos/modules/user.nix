# User module: moonblade user configuration
# NOTE: initialPassword is set here for initial setup.
# Change password after first login with: passwd
{ config, lib, pkgs, ... }:

{
  # Create moonblade user
  users.users.moonblade = {
    isNormalUser = true;
    home = "/home/moonblade";
    description = "Moonblade";
    
    # Groups for desktop usage
    extraGroups = [ 
      "wheel"       # sudo access
      "audio"       # audio devices
      "video"       # video devices
      "networkmanager"  # network management
      "input"       # input devices
    ];
    
    # Initial password - change after first login!
    # This is only used for initial cloud-init setup
    initialPassword = "changeme";
    
    # SSH authorized keys for passwordless SSH
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvVn+sGksOE/YyWYo4meihsZxj3q7KPuzG2Yyfye7+H mb work lap"
    ];
    
    # Default shell
    shell = pkgs.zsh;
  };

  # Enable zsh
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "sudo" "docker" "kubectl" ];
    };
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # MOTD (Message of the Day)
  users.motd = with config; ''
    Welcome to ${networking.hostName}!

    This is a NixOS desktop with i3 window manager.
    
    Quick i3 shortcuts (vim-style):
      Mod+Enter     - Open terminal (alacritty)
      Mod+d         - Application launcher (rofi)
      Mod+Shift+q   - Close focused window
      Mod+h/j/k/l   - Focus left/down/up/right
      Mod+Shift+h/j/k/l - Move window
      Mod+1-9       - Switch workspace
      Mod+Shift+e   - Exit i3
    
    (Mod key = Super/Windows key)

    OS:      NixOS ${system.nixos.release} (${system.nixos.codeName})
    Version: ${system.nixos.version}
  '';
}
