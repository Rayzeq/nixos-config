{ pkgs, ... }: {
  hm.home.packages = with pkgs; [
    pavucontrol
    gimp3-with-plugins
  ];
  hm.programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
    ];
  };
}
