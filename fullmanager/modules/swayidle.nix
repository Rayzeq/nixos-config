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
    enable = swayidleOptions.enable;
    package = swayidleOptions.package;

    timeouts = swayidleOptions.timeouts;
    events = swayidleOptions.events;
  };

  config.hm.services.swayidle = lib.mkIf cfg.enable cfg;
}
