{ pkgs, config }: ''
  ${pkgs.kdePackages.plasma-workspace}/bin/lookandfeeltool --apply org.kde.breeze.desktop
  ${pkgs.dbus}/bin/dbus-send --session --dest=org.kde.KWin --type=method_call /KWin org.kde.KWin.reloadConfig
''
