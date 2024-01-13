{ pkgs, lib, globals, ... }:
let
  config = import ../configuration/eww {
    inherit globals;
  };
in
if config.enable then {
  packages = with pkgs; [ playerctl ];
  python-packages = ps: with ps; [ psutil pyudev pulsectl pyroute2 pyric ];

  programs.eww = {
    enable = true;
    package = (import ../packages/eww) { inherit pkgs lib; };
    configDir = config.configDir;
  };

  # xdg.configFile."eww" = {
  #   # source = config.configDir;
  #   recursive = true;
  # };

  # xdg.configFile."eww/test.yuck".text = "test";
} else { }
