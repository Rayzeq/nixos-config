{ home-manager, lib, config, ... }:
let
  cfg = config.nh;

  nhOptions = lib.getOptions "${home-manager}/modules/programs/nh.nix";
in
{
  options.nh = {
    inherit (nhOptions) enable package flake homeFlake osFlake darwinFlake;
  };

  config.hm.programs.nh = lib.mkIf cfg.enable cfg;
}
