{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
  };
  outputs = { nixpkgs, nixpkgs-unstable, hermes-agent, ... }:
    let
      system = "x86_64-linux";
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.luna = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          hermes-agent.nixosModules.default
          {
            nixpkgs.config.allowUnfree = true;
            # Overlay ollama-cuda from unstable (0.32.x) to support qwen3.8:27b
            nixpkgs.overlays = [
              (final: prev: {
                ollama-cuda = pkgsUnstable.ollama-cuda;
              })
            ];
          }
          ./configuration.nix
          ./modules.nix
        ];
      };
    };
}
