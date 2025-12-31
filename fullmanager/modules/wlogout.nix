{ lib, pkgs, config, ... }:
let
  cfg = config.wlogout;

  wlogoutOptions = (import <home-manager/modules/programs/wlogout.nix> {
    inherit lib pkgs;
    config = { };
  }).options.programs.wlogout;
in
{
  options.wlogout = {
    inherit (wlogoutOptions) enable package layout style;
  };

  config.hm.programs.wlogout = lib.mkIf cfg.enable cfg;
}
