{ home-manager, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.mangohud;

  mangohudOptions = lib.getOptions "${home-manager}/modules/programs/mangohud.nix";

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
    groups: lib.concatMapStringsSep "\n" (group: lib.concatStringsSep "\n" (lib.mapAttrsToList renderLine group)) groups + "\n";
in
{
  options.mangohud = {
    inherit (mangohudOptions) enable package enableSessionWide;

    settings = mkOption {
      type = with types; listOf (attrsOf settingsType);
      default = { };
      example = lib.literalExpression ''
        [
          {
            output_folder = ~/Documents/mangohud/;
            full = true;
          }
          {
            gpu_stats = true;
            gpu_text = "GPU";
          }
        ]
      '';
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/MangoHud/MangoHud.conf`. See
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
