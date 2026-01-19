{ home-manager, lib, config, ... }:
let
  cfg = config;

  homeOptions = lib.getOptions "${home-manager}/modules/home-environment.nix";
in
{
  imports = lib.getModules ./. [ "default.nix" ];

  options = {
    inherit (homeOptions) shellAliases;
  };
  config.hm.home.shellAliases = cfg.shellAliases;
}
