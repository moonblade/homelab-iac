{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, hermes-agent, home-manager, ... }:
    {
      nixosConfigurations.luna = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          hermes-agent.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            nixpkgs.config.allowUnfree = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          ./configuration.nix
          ./modules.nix
        ];
      };
    };
}
