{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkIf types literalExpression;
  cfg = config.hyprpaper;

  hyprpaperOptions = (import <home-manager/modules/services/hyprpaper.nix> {
    inherit lib pkgs;
    config = { };
  }).options.services.hyprpaper;
in
{
  options.hyprpaper = {
    enable = hyprpaperOptions.enable;
    package = hyprpaperOptions.package;

    preload = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "Wallpapers to preload. In order to be used, a wallpaper must be preloaded.";
      example = literalExpression ''
        [
          "/share/wallpapers/buttons.png"
          "/share/wallpapers/cat_pacman.png"
        ]
      '';
    };

    wallpaper = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = "Mapping of monitor name to wallpaper. Use an empty monitor name as a fallback";
      example = literalExpression ''
        {
          "" = "/share/wallpapers/buttons.png";
          "DP-3" = "/share/wallpapers/buttons.png";
          "DP-1" = "/share/wallpapers/cat_pacman.png";
        };
      '';
    };
  };

  config.hm.services.hyprpaper = mkIf cfg.enable {
    enable = cfg.enable;
    package = cfg.package;
    settings = {
      preload = cfg.preload;
      wallpaper = builtins.attrValues (builtins.mapAttrs (monitor: wallpaper: "${monitor},${wallpaper}") cfg.wallpaper);
    };
  };
}
