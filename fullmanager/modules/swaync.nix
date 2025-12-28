{ lib, pkgs, config, ... }:
let
  cfg = config.swaync;

  swayncOptions = (import <home-manager/modules/services/swaync.nix> {
    inherit lib pkgs;
    config = { };
  }).options.services.swaync;
in
{
  options.swaync = {
    enable = swayncOptions.enable;
    package = swayncOptions.package;

    style = swayncOptions.style;
    settings = swayncOptions.settings;
  };

  config.hm.services.swaync = lib.mkIf cfg.enable cfg;
}
