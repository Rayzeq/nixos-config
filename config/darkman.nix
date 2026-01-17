{ pkgs, lib, config, ... }: {
  darkman = {
    enable = lib.mkDefault true;

    settings = {
      lat = config.globals.latitude;
      lng = config.globals.longitude;
      usegeoclue = false;
    };

    darkModeScripts.kde = ''
      ${pkgs.kdePackages.plasma-workspace}/bin/lookandfeeltool --apply org.kde.breezedark.desktop
      ${pkgs.dbus}/bin/dbus-send --session --dest=org.kde.KWin --type=method_call /KWin org.kde.KWin.reloadConfig
    '';
    lightModeScripts.kde = ''
      ${pkgs.kdePackages.plasma-workspace}/bin/lookandfeeltool --apply org.kde.breeze.desktop
      ${pkgs.dbus}/bin/dbus-send --session --dest=org.kde.KWin --type=method_call /KWin org.kde.KWin.reloadConfig
    '';
  };
}
