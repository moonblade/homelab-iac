{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, nixpkgs-unstable, hermes-agent, home-manager, ... }:
    let
      system = "x86_64-linux";
      # Pull sunshine from unstable — it has autoAddDriverRunpath which bakes
      # /run/opengl-driver/lib into the binary RPATH at build time, enabling NVENC.
      # LD_LIBRARY_PATH is stripped for setcap binaries, so RPATH is required.
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };
    in
    {
      nixosConfigurations.luna = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgsUnstable; };
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
