{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
  };
  outputs = { nixpkgs, ... }:
    {
      nixosConfigurations.luna = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
          }
          ./configuration.nix
          ./modules.nix
        ];
      };
    };
}
