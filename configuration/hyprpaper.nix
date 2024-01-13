{ globals, ... }: {
  enable = true;

  preload = [
    "${globals.dataFile."wallpapers/current.png".target}"
    "${globals.dataFile."wallpapers/light.png".target}"
    "${globals.dataFile."wallpapers/dark.png".target}"
  ];
  wallpaper = {
    screen = "";
    file = "${globals.dataFile."wallpapers/current.png".target}";
  };
}
