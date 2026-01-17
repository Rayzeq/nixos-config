{ home-manager, lib, config, ... }:
let
  cfg = config.swaync;

  swayncOptions = lib.getOptions "${home-manager}/modules/services/swaync.nix";
in
{
  options.swaync = {
    inherit (swayncOptions) enable package style settings;
  };

  config.hm.services.swaync = lib.mkIf cfg.enable (lib.mkMerge [
    {
      settings."$schema" = "${cfg.package}/etc/xdg/swaync/configSchema.json";
    }
    cfg
  ]);
}
