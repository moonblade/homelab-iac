{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    hermes-agent.url = "github:NousResearch/hermes-agent";
  };
  outputs = { nixpkgs, hermes-agent, ... }:
    {
      nixosConfigurations.luna = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          hermes-agent.nixosModules.default
          {
            nixpkgs.config.allowUnfree = true;
          }
          ./configuration.nix
          ./modules.nix
        ];
      };
    };
}
