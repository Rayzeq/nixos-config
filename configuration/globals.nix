{ pkgs, ... }: {
  font = {
    package = pkgs.fira-code;
    family = "Fira Code";
  };

  dataFile."wallpapers/light2.png".source = ../fullmanager/config/wallpapers/light.png;

  theme = {
    background-color = "rgba(0, 0, 0, 0.8)";
    background-color-active = "rgba(176, 165, 255, 0.8)";
    background-color-hover = "rgba(114, 211, 254, 0.8)";
  };
}
