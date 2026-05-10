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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-index-database, agenix, disko, ... }:
    let
      lib = import ./lib.nix nixpkgs.legacyPackages.x86_64-linux nixpkgs.lib;
    in
    {
      nixosConfigurations = lib.nixosSystems {
        specialArgs = { inherit nixpkgs home-manager agenix; };
        modules = [
          home-manager.nixosModules.home-manager
          nix-index-database.nixosModules.default
          agenix.nixosModules.default
          disko.nixosModules.disko

          ./secrets/default.nix
          ./_legacy/configuration.nix
        ];
      };
      packages.x86_64-linux.iso = self.nixosConfigurations.iso.config.system.build.isoImage;
    };
}
