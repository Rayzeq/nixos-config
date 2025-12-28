{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf types;
  cfg = config.swaylock;
in
{
  options.swaylock = {
    enable = mkEnableOption "swaylock";
    package = mkPackageOption pkgs "swaylock" { };

    settings = mkOption {
      type =
        with types;
        attrsOf (oneOf [
          bool
          float
          int
          path
          str
        ]);
      default = { };
      description = ''
        Default arguments to {command}`swaylock`. An empty set
        disables configuration generation.
      '';
      example = {
        color = "808080";
        font-size = 24;
        indicator-idle-visible = false;
        indicator-radius = 100;
        line-color = "ffffff";
        show-failed-attempts = true;
      };
    };
  };

  config = mkIf cfg.enable {
    hm.programs.swaylock = {
      enable = true;
      package = cfg.package;
      settings = cfg.settings;
    };
    system.security.pam.services.swaylock = { };
  };
}
