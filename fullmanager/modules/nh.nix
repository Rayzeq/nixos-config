{ home-manager, lib, pkgs, config, ... }:
let
  cfg = config.nh;

  nhOptions = (import "${home-manager}/modules/programs/nh.nix" {
    inherit lib pkgs;
    config = { };
  }).options.programs.nh;
in
{
  options.nh = {
    inherit (nhOptions) enable package flake homeFlake osFlake darwinFlake;
  };

  config.hm.programs.nh = lib.mkIf cfg.enable cfg;
}
