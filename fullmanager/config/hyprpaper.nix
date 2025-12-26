{ config, ... }: {
  xdg.dataFile = {
    "wallpapers/light.png".source = ./wallpapers/light.png;
    "wallpapers/dark.png".source = ./wallpapers/dark.png;
    "wallpapers/current.png" = {
      source = ./wallpapers/light.png;
      force = true;
    };
  };
  hyprpaper = {
    enable = true;

    preload = [
      "${config.xdg.dataFile."wallpapers/current.png".target}"
      "${config.xdg.dataFile."wallpapers/light.png".target}"
      "${config.xdg.dataFile."wallpapers/dark.png".target}"
    ];
    wallpaper = {
      "" = "${config.xdg.dataFile."wallpapers/current.png".target}";
    };
  };
}
