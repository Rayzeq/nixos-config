{ lib, pkgs, config, ... }:
let
  cfg = config.wlsunset;

  wlsunsetOptions = (import <home-manager/modules/services/wlsunset.nix> {
    inherit lib pkgs;
    config = { };
  }).options.services.wlsunset;
in
{
  options.wlsunset = {
    enable = wlsunsetOptions.enable;
    package = wlsunsetOptions.package;

    latitude = wlsunsetOptions.latitude;
    longitude = wlsunsetOptions.longitude;
  };

  config.hm.services.wlsunset = lib.mkIf cfg.enable cfg;
}
