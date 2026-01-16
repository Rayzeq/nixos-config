{ nixpkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.pam;

  pamOptions = (lib.getOptions "${nixpkgs}/nixos/modules/security/pam.nix").security.pam;
in
{
  options.pam.u2f = {
    enable = pamOptions.u2f.enable;

    cue = (pamOptions.u2f.settings.type.getSubOptions { }).cue;
    keys = mkOption {
      type = with types; attrsOf (listOf str);
      default = { };
      description = ''
        Public keys of users.
      '';
    };
  };

  config.system.security.pam.u2f = mkIf cfg.u2f.enable {
    enable = cfg.u2f.enable;

    settings = {
      cue = cfg.u2f.cue;
      authfile = builtins.toFile "u2f_mappings" (lib.concatStringsSep "\n" (
        lib.mapAttrsToList (user: ids: lib.concatStringsSep ":" ([ user ] ++ ids)) cfg.u2f.keys
      ));
    };
  };
}
