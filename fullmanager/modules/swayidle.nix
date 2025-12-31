{ lib, pkgs, config, ... }:
let
  cfg = config.swayidle;

  swayidleOptions = (import <home-manager/modules/services/swayidle.nix> {
    inherit lib pkgs;
    config = { };
  }).options.services.swayidle;
in
{
  options.swayidle = {
    inherit (swayidleOptions) enable package timeouts events;
  };

  config.hm.services.swayidle = lib.mkIf cfg.enable cfg;
}
