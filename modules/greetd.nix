{ nixpkgs, pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.greetd;

  greetdOptions = lib.getOptions "${nixpkgs}/nixos/modules/services/display-managers/greetd.nix";
in
{
  options.greetd = {
    inherit (greetdOptions) enable package settings useTextGreeter;

    enableNumlock = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Enable the numlock key in text greeters.
      '';
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
