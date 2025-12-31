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
    inherit (wlsunsetOptions) enable package latitude longitude;
  };

  config.hm.services.wlsunset = lib.mkIf cfg.enable cfg;
}
