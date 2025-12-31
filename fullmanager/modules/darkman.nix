{ lib, pkgs, config, ... }:
let
  cfg = config.darkman;

  darkmanOptions = (import <home-manager/modules/services/darkman.nix> {
    inherit lib pkgs;
    config = { };
  }).options.services.darkman;
in
{
  options.darkman = {
    inherit (darkmanOptions) enable package settings darkModeScripts lightModeScripts;
  };

  config.hm.services.darkman = lib.mkIf cfg.enable cfg;
}
