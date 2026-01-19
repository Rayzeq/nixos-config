{ home-manager, lib, config, ... }:
let
  cfg = config;

  homeOptions = lib.getOptions "${home-manager}/modules/home-environment.nix";
in
{
  options = {
    inherit (homeOptions) packages;
  };
  config.hm.home.packages = cfg.packages;
}
