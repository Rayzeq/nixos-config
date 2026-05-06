{ pkgs, ... }: {
  hm.home.packages = with pkgs; [
    vlc
    pavucontrol
    gimp3-with-plugins
  ];
}
