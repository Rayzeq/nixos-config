{ lib, pkgs, config, ... }:
let
  cfg = config.greetd;

  greetdOptions = (import <nixos/nixos/modules/services/display-managers/greetd.nix> {
    inherit lib pkgs;
    config = { };
  }).options.services.greetd;
in
{
  options.greetd = {
    inherit (greetdOptions) enable package settings useTextGreeter;
  };

  config.system.services.greetd = lib.mkIf cfg.enable cfg;
}
