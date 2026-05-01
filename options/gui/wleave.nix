{ home-manager, lib, config, ... }:
let
  cfg = config.wleave;

  wleaveOptions = lib.getOptions "${home-manager}/modules/programs/wleave.nix";
in
{
  options.wleave = {
    inherit (wleaveOptions) enable package settings style;
  };

  config.hm.programs.wleave = lib.mkIf cfg.enable cfg;
}
