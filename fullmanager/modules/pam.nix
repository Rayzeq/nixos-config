{ nixpkgs, lib, pkgs, config, ... }:
let
  cfg = config.pam;

  pamOptions = (import "${nixpkgs}/nixos/modules/security/pam.nix" {
    inherit lib pkgs;
    config = { };
  }).options.security.pam;
in
{
  options.pam.u2f = {
    enable = pamOptions.u2f.enable;

    cue = (pamOptions.u2f.settings.type.getSubOptions { }).cue;
    keys = lib.mkOption {
      type = with lib.types; attrsOf (listOf str);
    };
  };

  config.system.security.pam.u2f = lib.mkIf cfg.u2f.enable {
    enable = cfg.u2f.enable;

    settings = {
      cue = cfg.u2f.cue;
      authfile = builtins.toFile "u2f_mappings" (lib.concatStringsSep "\n" (
        lib.mapAttrsToList (user: ids: lib.concatStringsSep ":" ([ user ] ++ ids)) cfg.u2f.keys
      ));
    };
  };
}
