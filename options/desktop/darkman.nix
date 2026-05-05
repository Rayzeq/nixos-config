{ home-manager, lib, config, ... }:
let
  cfg = config.darkman;

  darkmanOptions = lib.getOptions "${home-manager}/modules/services/darkman.nix";
in
{
  options.darkman = {
    inherit (darkmanOptions) enable package settings darkModeScripts lightModeScripts;
  };

  config.hm.services.darkman = lib.mkIf cfg.enable cfg;
}
