{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      plugins = [ "git" "z" "sudo" "history" "docker" ];
      theme = "agnoster";
    };

    # Add custom Zsh configuration here
    shellAliases = {
      ll = "ls -l";
      la = "ls -lha";
      k = "kubectl";
    };
  };

  users.users.root = {
    shell = pkgs.zsh;
  };

  # users.users.moonblade = {
  #   shell = pkgs.zsh;
  # };
}

