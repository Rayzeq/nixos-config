{ lib, pkgs, ... }:
with lib;
with builtins;
let
  globals = import ./config/globals.nix { inherit pkgs; self = globalsFinal; };
  globalsFinal = globals;

  fullmanager = evalModules {
    specialArgs = {
      inherit pkgs lib globals;
    };
    modules = [
      {
        options = {
          system = mkOption {
            type = types.attrsOf types.anything;
            default = { };
            description = "Options to forward to NixOS";
          };

          hm = mkOption {
            type = types.attrsOf types.anything;
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
  config = (fullmanager.config.system or { }) // {
    home-manager.sharedModules = [ fullmanager.config.hm or { } ];
  };
}
