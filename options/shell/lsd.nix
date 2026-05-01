{ home-manager, lib, config, ... }:
let
  cfg = config.lsd;

  lsdOptions = lib.getOptions "${home-manager}/modules/programs/lsd.nix";
in
{
  options.lsd = {
    inherit (lsdOptions) enable package;
  };
  config.hm.programs.lsd = lib.mkIf cfg.enable cfg;
}
