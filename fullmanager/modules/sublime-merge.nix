{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkOption mkPackageOption mkIf;
  cfg = config.sublime-merge;
  configDirectory = "sublime-merge/Packages/User/";
  jsonFormat = pkgs.formats.json { };
in
{
  options.sublime-merge = {
    enable = mkEnableOption "Sublime Merge";
    package = mkPackageOption pkgs "sublime-merge" { };

    settings = mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        Sublime Merge's user settings.
      '';
    };
  };

  config = mkIf cfg.enable {
    hm.home.packages = [ cfg.package ];
    hm.xdg.configFile = {
      "${configDirectory}/Preferences.sublime-settings".source = jsonFormat.generate "sublime-merge-settings" cfg.settings;
    };
  };
}
