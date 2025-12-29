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
    enable = greetdOptions.enable;
    package = greetdOptions.package;

    settings = greetdOptions.settings;
    useTextGreeter = greetdOptions.useTextGreeter;
  };

  config.system.services.greetd = lib.mkIf cfg.enable cfg;
}
