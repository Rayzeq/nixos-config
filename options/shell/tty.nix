{ nixpkgs, lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.tty;

  consoleOptions = lib.getOptions "${nixpkgs}/nixos/modules/config/console.nix";
in
{
  options.tty = {
    keymap = consoleOptions.keyMap;
    enableNumlock = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Whether to enable the num lock key by default on TTYs.";
    };
  };

  config.system = {
    console.keyMap = cfg.keymap;
    # Can't use directly preStart because nixos wraps it in a script
    # and systemd can't expand the %I
    systemd.services."getty@".serviceConfig.ExecStartPre = mkIf
      cfg.enableNumlock
      "${pkgs.bash}/bin/sh -c '${pkgs.kbd}/bin/setleds -D +num < /dev/%I'";
  };
}
