{ pkgs, ... }: {
  font = {
    package = pkgs.fira-code;
    family = "Fira Code";
  };
  latitude = 46.6;
  longitude = 1.6;

  dataFile."wallpapers/light.png".source = ./wallpapers/light.png;
  dataFile."wallpapers/dark.png".source = ./wallpapers/dark.png;
  dataFile."wallpapers/current.png" = {
    source = ./wallpapers/light.png;
    force = true;
  };

  theme = {
    background-color = "rgba(0, 0, 0, 0.8)";
    background-color-active = "rgba(176, 165, 255, 0.8)";
    background-color-hover = "rgba(114, 211, 254, 0.8)";
  };
}
