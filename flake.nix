{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = import ./lib.nix nixpkgs.lib;
    in
    {
      nixosConfigurations = lib.nixosSystems {
        inherit nixpkgs home-manager;
        alpha = {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ./legacy/configuration.nix
          ];
        };
      };
    };
}
