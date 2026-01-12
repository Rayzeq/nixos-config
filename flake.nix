{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-index-database, ... }:
    let
      lib = import ./lib.nix nixpkgs.lib;
    in
    {
      nixosConfigurations = lib.nixosSystems {
        inherit nixpkgs home-manager;
        alpha = {
          system = "x86_64-linux";
          stateVersion = "23.05";

          modules = [
            nix-index-database.nixosModules.default
            ./legacy/configuration.nix
          ];
        };
      };
    };
}
