{ home-manager, lib, config, ... }:
let
  cfg = config.git;

  gitOptions = lib.getOptions "${home-manager}/modules/programs/git.nix";
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
