{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf types literalExpression;
  cfg = config.hyprpaper;
in
{
  options.hyprpaper = {
    enable = mkEnableOption "Hyprpaper, Hyprland's wallpaper daemon";
    package = mkPackageOption pkgs "hyprpaper" { nullable = true; };

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

  config = mkIf cfg.enable {
    hm.services.hyprpaper = {
      enable = true;
      package = cfg.package;
      settings = {
        preload = cfg.preload;
        wallpaper = builtins.attrValues (builtins.mapAttrs (monitor: wallpaper: "${monitor},${wallpaper}") cfg.wallpaper);
      };
    };
  };
}
