{ lib, pkgs, ... }:
let
  inherit (lib) evalModules mkOption;
  customTypes = import ./types.nix { inherit lib; };

  globals = import ./config/globals.nix { inherit pkgs; self = globalsFinal; };
  globalsFinal = globals;

  fullmanager = evalModules {
    specialArgs = { inherit pkgs lib globals; };
    modules = [
      {
        options = {
          system = mkOption {
            type = customTypes.deferMerge;
            default = { };
            description = "Options to forward to NixOS";
          };

          hm = mkOption {
            type = customTypes.deferMerge;
            default = { };
            description = "Options to forward to Home Manager";
          };
        };
      }
      ./config
      ./modules
    ];
  };
in
{
  config = lib.mkMerge [
    (fullmanager.config.system or { })
    {
      home-manager.users.root = fullmanager.config.hm or { };
      home-manager.users.zacharie = fullmanager.config.hm or { };
    }
  ];
}
