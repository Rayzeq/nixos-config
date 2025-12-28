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
    enable = darkmanOptions.enable;
    package = darkmanOptions.package;

    settings = darkmanOptions.settings;
    darkModeScripts = darkmanOptions.darkModeScripts;
    lightModeScripts = darkmanOptions.lightModeScripts;
  };

  config.hm.services.darkman = lib.mkIf cfg.enable cfg;
}
