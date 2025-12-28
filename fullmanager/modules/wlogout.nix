{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf types;
  cfg = config.wlogout;

  jsonFormat = pkgs.formats.json { };
  wlogoutLayoutConfig =
    types.submodule {
      freeformType = jsonFormat.type;

      options = {
        label = mkOption {
          type = with types; str;
          default = "";
          example = "shutdown";
          description = "CSS label of button.";
        };

        action = mkOption {
          type = with types; either path str;
          default = "";
          example = "systemctl poweroff";
          description = "Command to execute when clicked.";
        };

        text = mkOption {
          type = with types; str;
          default = "";
          example = "Shutdown";
          description = "Text displayed on button.";
        };

        keybind = mkOption {
          type = with types; str;
          default = "";
          example = "s";
          description = "Keyboard character to trigger this action.";
        };

        height = mkOption {
          type = with types; nullOr (numbers.between 0 1);
          default = null;
          example = 0.5;
          description = "Relative height of tile.";
        };

        width = mkOption {
          type = with types; nullOr (numbers.between 0 1);
          default = null;
          example = 0.5;
          description = "Relative width of tile.";
        };

        circular = mkOption {
          type = with types; nullOr bool;
          default = null;
          example = true;
          description = "Make button circular.";
        };
      };
    };
in
{
  options.wlogout = {
    enable = mkEnableOption "wlogout";
    package = mkPackageOption pkgs "wlogout" { };

    layout = mkOption {
      type = with types; listOf wlogoutLayoutConfig;
      default = [ ];
      description = ''
        Layout configuration for wlogout, see <https://github.com/ArtsyMacaw/wlogout#config>
        for supported values.
      '';
      example = lib.literalExpression ''
        [
          {
            label = "shutdown";
            action = "systemctl poweroff";
            text = "Shutdown";
            keybind = "s";
          }
        ]
      '';
    };

    style = mkOption {
      type = with types; nullOr (either path lines);
      default = null;
      description = ''
        CSS style of the bar.

        See <https://github.com/ArtsyMacaw/wlogout#style>
        for the documentation.

        If the value is set to a path literal, then the path will be used as the css file.
      '';
      example = ''
        window {
          background: #16191C;
        }

        button {
          color: #AAB2BF;
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    hm.programs.wlogout = {
      enable = true;
      package = cfg.package;
      layout = cfg.layout;
      style = cfg.style;
    };
  };
}
