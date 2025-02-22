{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.bettermanager.sublime-merge;
  configDirectory = "sublime-merge/Packages/User/";
  jsonFormat = pkgs.formats.json { };
in
{
  options.bettermanager.sublime-merge = {
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
    home.packages = [ cfg.package ];
    xdg.configFile = {
      "${configDirectory}/Preferences.sublime-settings".source = jsonFormat.generate "sublime-merge-settings" cfg.settings;
    };
  };
}
