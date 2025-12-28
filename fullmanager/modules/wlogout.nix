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
    enable = wlogoutOptions.enable;
    package = wlogoutOptions.package;

    layout = wlogoutOptions.layout;
    style = wlogoutOptions.style;
  };

  config.hm.programs.wlogout = lib.mkIf cfg.enable cfg;
}
