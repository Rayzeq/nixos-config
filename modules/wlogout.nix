{ home-manager, lib, config, ... }:
let
  cfg = config.wlogout;

  wlogoutOptions = lib.getOptions "${home-manager}/modules/programs/wlogout.nix";
in
{
  options.wlogout = {
    inherit (wlogoutOptions) enable package layout style;
  };

  config.hm.programs.wlogout = lib.mkIf cfg.enable cfg;
}
