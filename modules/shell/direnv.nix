{ home-manager, lib, config, ... }:
let
  cfg = config.direnv;

  direnvOptions = lib.getOptions "${home-manager}/modules/programs/direnv.nix";
in
{
  options.direnv = {
    inherit (direnvOptions) enable package config nix-direnv;
  };
  config.hm.programs.direnv = lib.mkIf cfg.enable {
    inherit (cfg) enable package nix-direnv;
    config = {
      global = {
        # this is necessary to allow escaping \x1b
        log_format = builtins.fromJSON ''"${cfg.config.global.log_format}"'';
      } // (removeAttrs cfg.config.global [ "log_format" ]);
    } // (removeAttrs cfg.config [ "global" ]);
  };
}
