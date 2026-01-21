{ home-manager, pkgs, lib, config, ... }:
let
  cfg = config.wlogout;

  wlogoutOptions = lib.getOptions "${home-manager}/modules/programs/wlogout.nix";
in
{
  options.wlogout = {
    inherit (wlogoutOptions) enable package layout style;
  };

  config.hm.programs.wlogout = lib.mkIf cfg.enable {
    inherit (cfg) enable package style;
    layout = map (layout: layout // { action = pkgs.writeScript "wlogout-${layout.label}" layout.action; }) cfg.layout;
  };
}
