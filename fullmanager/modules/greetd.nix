{ nixpkgs, lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.greetd;

  greetdOptions = (import "${nixpkgs}/nixos/modules/services/display-managers/greetd.nix" {
    inherit lib pkgs;
    config = { };
  }).options.services.greetd;
in
{
  options.greetd = {
    inherit (greetdOptions) enable package settings useTextGreeter;

    enableNumlock = mkOption {
      type = types.bool;
    };
  };

  config.system = mkIf cfg.enable {
    services.greetd = {
      inherit (cfg) enable package useTextGreeter settings;
    };
    systemd.services.greetd.preStart = mkIf
      cfg.enableNumlock
      "${pkgs.bash}/bin/sh -c '${pkgs.kbd}/bin/setleds -D +num < /dev/tty1'";
  };
}
