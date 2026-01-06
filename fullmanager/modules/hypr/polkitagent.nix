{ lib, pkgs, config, ... }:
let
  cfg = config.hypr.polkitagent;

  hypridleOptions = (import <home-manager/modules/services/hyprpolkitagent.nix> {
    inherit lib pkgs;
    config = { };
  }).options.services.hyprpolkitagent;
in
{
  options.hypr.polkitagent = {
    inherit (hypridleOptions) enable package;
  };

  config.hm.services.hyprpolkitagent = lib.mkIf cfg.enable cfg;
}
