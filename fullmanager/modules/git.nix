{ lib, pkgs, config, ... }:
let
  cfg = config.git;

  gitOptions = (import <home-manager/modules/programs/git.nix> {
    inherit lib pkgs;
    config = { };
  }).options.programs.git;
in
{
  options.git = {
    enable = gitOptions.enable;
    package = gitOptions.package;

    settings = gitOptions.settings;
  };
  config.hm.programs.git = lib.mkIf cfg.enable cfg;
}
