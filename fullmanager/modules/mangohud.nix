{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.mangohud;

  mangohudOptions = (import <home-manager/modules/programs/mangohud.nix> {
    inherit lib pkgs;
    config = { };
  }).options.programs.mangohud;

  settingsType =
    with types;
    (oneOf [
      bool
      int
      float
      str
      path
      (listOf (oneOf [
        int
        str
      ]))
    ]);

  renderOption =
    option:
    rec {
      int = toString option;
      float = int;
      path = int;
      bool = "0"; # "on/off" opts are disabled with `=0`
      string = option;
      list = lib.concatStringsSep "," (lib.forEach option (x: toString x));
    }.${builtins.typeOf option};

  renderLine = k: v: (if lib.isBool v && v then k else "${k}=${renderOption v}");
  renderSettings =
    groups: lib.concatStringsSep "\n" (map (group: lib.concatStringsSep "\n" (lib.mapAttrsToList renderLine group)) groups) + "\n";
in
{
  options.mangohud = {
    inherit (mangohudOptions) enable package enableSessionWide;

    settings = mkOption {
      type = with types; listOf (attrsOf settingsType);
      default = { };
      example = lib.literalExpression ''
        {
          output_folder = ~/Documents/mangohud/;
          full = true;
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/MangoHud/MangoHud.conf`. See
        <https://github.com/flightlessmango/MangoHud/blob/master/data/MangoHud.conf>
        for the default configuration.
      '';
    };
  };

  config.hm = mkIf cfg.enable {
    programs.mangohud = {
      inherit (cfg) enable package enableSessionWide;
    };
    xdg.configFile."MangoHud/MangoHud.conf" = mkIf (cfg.settings != { }) {
      text = renderSettings cfg.settings;
    };
  };
}
