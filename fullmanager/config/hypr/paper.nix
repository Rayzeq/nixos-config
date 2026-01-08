{ pkgs, lib, config, ... }:
let
  current = config.xdg.dataFile."wallpapers/current.png".target;
  light = config.xdg.dataFile."wallpapers/light.png".target;
  dark = config.xdg.dataFile."wallpapers/dark.png".target;
in
{
  xdg.dataFile = {
    "wallpapers/light.png".source = ./wallpapers/light.png;
    "wallpapers/dark.png".source = ./wallpapers/dark.png;
    "wallpapers/current.png" = {
      source = ./wallpapers/light.png;
      force = true;
    };
  };
  hypr.paper = {
    enable = lib.mkDefault true;

    splash = false;
    wallpapers = [
      {
        monitor = "";
        path = "${current}";
      }
    ];
  };
  darkman = {
    darkModeScripts.hyprpaper = ''
      ${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper ',${dark}'
      ${pkgs.coreutils-full}/bin/ln -sf $(${pkgs.coreutils-full}/bin/readlink ${dark}) ${current}
    '';
    lightModeScripts.hyprpaper = ''
      ${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper ',${light}'
      ${pkgs.coreutils-full}/bin/ln -sf $(${pkgs.coreutils-full}/bin/readlink ${light}) ${current}
    '';
  };
}
