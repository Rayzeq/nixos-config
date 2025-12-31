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
    inherit (swayncOptions) enable package style settings;
  };

  config.hm.services.swaync = lib.mkIf cfg.enable (lib.mkMerge [
    {
      settings."$schema" = "${pkgs.swaynotificationcenter}/etc/xdg/swaync/configSchema.json";
    }
    cfg
  ]);
}
