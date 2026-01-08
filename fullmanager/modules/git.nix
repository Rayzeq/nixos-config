{ home-manager, lib, pkgs, config, ... }:
let
  cfg = config.git;

  gitOptions = (import "${home-manager}/modules/programs/git.nix" {
    inherit lib pkgs;
    config = { };
  }).options.programs.git;
in
{
  options.git = {
    inherit (gitOptions) enable package settings;
  };
  config = lib.mkIf cfg.enable {
    hm.programs.git = cfg;
    system.programs.git = {
      inherit (cfg) enable package;
    };
  };
}
