{ home-manager, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.hypr.paper;

  hyprpaperOptions = lib.getOptions "${home-manager}/modules/services/hyprpaper.nix";

  wallpaperModule = types.submodule {
    options = {
      monitor = mkOption {
        type = types.str;
        default = "";
        example = "DP-3";
        description = ''
          Monitor to display this wallpaper on. If empty, will use this wallpaper as a fallback.
        '';
      };
      path = mkOption {
        type = types.str;
        example = "/share/wallpapers/buttons.png";
        description = ''
          Path to an image file or a directory containing image files (non recursively).
        '';
      };
      fit-mode = mkOption {
        type = types.enum [ "contain" "cover" "tile" "fill" ];
        default = "cover";
        example = "tile";
        description = ''
          Determines how to display the image.
        '';
      };
      timeout = mkOption {
        type = types.int;
        default = 30;
        example = 60;
        description = ''
          Timeout between each wallpaper change (in seconds, if path is a directory).
        '';
      };
    };
  };
in
{
  options.hypr.paper = {
    inherit (hyprpaperOptions) enable package;

    splash = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Enable rendering of the hyprland splash over the wallpaper.
      '';
    };
    wallpapers = mkOption {
      type = with types; listOf wallpaperModule;
      default = [ ];
      description = ''
        List of wallpapers to apply.
      '';
    };
  };

  config.hm.services.hyprpaper = mkIf cfg.enable {
    inherit (cfg) enable package;
    settings = {
      inherit (cfg) splash;
      wallpaper = map
        (wallpaper: {
          inherit (wallpaper) monitor path;
          fit_mode = wallpaper.fit-mode;
          timeout = wallpaper.timeout;
        })
        cfg.wallpapers;
    };
  };
}
