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
        modules = [
          home-manager.nixosModules.home-manager
          nix-index-database.nixosModules.default
          ./_legacy/configuration.nix
        ];
      };
    };
}
