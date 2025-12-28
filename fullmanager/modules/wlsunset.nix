{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf types;
  cfg = config.wlsunset;
in
{
  options.wlsunset = {
    enable = mkEnableOption "wlsunset";
    package = mkPackageOption pkgs "wlsunset" { };

    latitude = mkOption {
      type = with types; nullOr (either str (either float int));
      default = null;
      example = -74.3;
      description = ''
        Your current latitude, between `-90.0` and
        `90.0`.
      '';
    };

    longitude = mkOption {
      type = with types; nullOr (either str (either float int));
      default = null;
      example = 12.5;
      description = ''
        Your current longitude, between `-180.0` and
        `180.0`.
      '';
    };
  };

  config = mkIf cfg.enable {
    hm.services.wlsunset = {
      enable = true;
      package = cfg.package;
      latitude = cfg.latitude;
      longitude = cfg.longitude;
    };
  };
}
