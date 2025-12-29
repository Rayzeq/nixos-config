{ lib, pkgs, config, ... }:
let
  cfg = config.tty;

  consoleOptions = (import <nixos/nixos/modules/config/console.nix> {
    inherit lib pkgs;
    config = { };
  }).options.console;
in
{
  options.tty = {
    keyMap = consoleOptions.keyMap;
    enableNumlock = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to enable the num lock key by default on TTYs";
    };
  };

  config = {
    system.console.keyMap = cfg.keyMap;
    # Can't use directly preStart because nixos wraps it in a script
    # and system can't expand the %I
    system.systemd.services."getty@".serviceConfig.ExecStartPre = lib.mkIf
      cfg.enableNumlock
      "${pkgs.bash}/bin/sh -c '${pkgs.kbd}/bin/setleds -D +num < /dev/%I'";
  };
}
