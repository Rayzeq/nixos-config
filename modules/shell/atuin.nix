{ home-manager, lib, config, ... }:
let
  cfg = config.atuin;

  atuinOptions = lib.getOptions "${home-manager}/modules/programs/atuin.nix";
in
{
  options.atuin = {
    inherit (atuinOptions) enable package settings;
  };
  config.hm.programs.atuin = lib.mkIf cfg.enable cfg;
}
