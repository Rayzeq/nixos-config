{ home-manager, lib, config, ... }:
let
  cfg = config.git;

  gitOptions = lib.getOptions "${home-manager}/modules/programs/git.nix";
in
{
  options.git = {
    inherit (gitOptions) enable package settings;
  };
  config.hm.programs.git = lib.mkIf cfg.enable cfg;
}
