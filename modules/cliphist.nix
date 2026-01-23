{ home-manager, lib, config, ... }:
let
  cfg = config.cliphist;

  cliphistOptions = lib.getOptions "${home-manager}/modules/services/cliphist.nix";
in
{
  options.cliphist = {
    inherit (cliphistOptions) enable package allowImages clipboardPackage extraOptions;
  };

  config.hm.services.cliphist = lib.mkIf cfg.enable cfg;
}
