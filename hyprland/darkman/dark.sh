{ pkgs, config }: ''
  ${pkgs.kdePackages.plasma-workspace}/bin/lookandfeeltool --apply org.kde.breezedark.desktop
  ${pkgs.dbus}/bin/dbus-send --session --dest=org.kde.KWin --type=method_call /KWin org.kde.KWin.reloadConfig
''
