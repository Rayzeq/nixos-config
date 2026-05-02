{ lib, ... }:
{
  home-manager.users.zacharie = { config, ... }: {
    services.playerctld.enable = true;
    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "eww open statusbar && ( nm-applet & blueman-applet & discord --enable-features=UseOzonePlatform --ozone-platform=wayland --start-minimized & )"
        ];

        env = lib.mapAttrsToList (name: value: name + "," + (toString value)) (config.systemd.user.sessionVariables // config.home.sessionVariables);
      };
    };
  };
}
