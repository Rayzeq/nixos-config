{ home-manager, lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.hypr.paper;

  hyprpaperOptions = (import "${home-manager}/modules/services/hyprpaper.nix" {
    inherit lib pkgs;
    config = { };
  }).options.services.hyprpaper;

  wallpaperModule = types.submodule {
    options = {
      monitor = mkOption { type = types.str; };
      path = mkOption { type = types.str; };
      fit_mode = mkOption {
        type = types.enum [ "contain" "cover" "tile" "fill" ];
        default = "cover";
      };
      timeout = mkOption { type = with types; nullOr int; default = null; };
    };
  };
in
{
  options.hypr.paper = {
    inherit (hyprpaperOptions) enable package;

    splash = mkOption {
      type = types.bool;
      default = true;
    };
    wallpapers = mkOption {
      type = with types; listOf wallpaperModule;
      default = { };
    };
  };

  config.hm.services.hyprpaper = mkIf cfg.enable {
    inherit (cfg) enable package;
    importantPrefixes = [ "monitor" ];
    settings = {
      inherit (cfg) splash;
      wallpaper = map
        (wallpaper: {
          inherit (wallpaper) monitor path fit_mode;
          timeout = mkIf (wallpaper.timeout != null) wallpaper.timeout;
        })
        cfg.wallpapers;
    };
  };
}
