{ pkgs, config }: ''
  ${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper eDP-1,/home/zacharie/.local/share/wallpapers/dark.png
  ${pkgs.coreutils-full}/bin/ln -sf $(${pkgs.coreutils-full}/bin/readlink /home/zacharie/.local/share/wallpapers/dark.png) /home/zacharie/.local/share/wallpapers/current.png

  ${pkgs.dbus}/bin/dbus-send --session --dest=org.kde.KWin --type=method_call /KWin org.kde.KWin.reloadConfig
  ${pkgs.kdePackages.plasma-workspace}/bin/lookandfeeltool --apply org.kde.breezedark.desktop
''
