{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, ... }:
    {
      nixosConfigurations.sirius = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./modules/k3s.nix
          ./modules/user.nix
          ./modules/zsh.nix
          ./modules/nvim.nix
          ./modules/tailscale.nix
        ];
      };
    };
}


