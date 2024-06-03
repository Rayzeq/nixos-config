{ pkgs, unstable, config }: ''
  ${unstable.hyprland}/bin/hyprctl hyprpaper wallpaper eDP-1,/home/zacharie/.local/share/wallpapers/light.png
  ${pkgs.coreutils-full}/bin/ln -sf $(${pkgs.coreutils-full}/bin/readlink /home/zacharie/.local/share/wallpapers/light.png) /home/zacharie/.local/share/wallpapers/current.png
''
