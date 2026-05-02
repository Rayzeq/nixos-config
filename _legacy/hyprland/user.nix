{ pkgs, lib, ... }:
{
  home-manager.users.zacharie = { config, ... }: {
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-hyprland kdePackages.xdg-desktop-portal-kde ];
      config = {
        hyprland = {
          default = [
            "hyprland"
            "kde"
          ];
          "org.freedesktop.impl.portal.Settings" = [
            "darkman"
          ];
        };
      };
    };

    services.playerctld.enable = true;
    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "eww open statusbar && ( nm-applet & blueman-applet & discord --enable-features=UseOzonePlatform --ozone-platform=wayland --start-minimized & )"
        ];

        env = lib.mapAttrsToList (name: value: name + "," + (toString value)) (config.systemd.user.sessionVariables // config.home.sessionVariables);

        bind = [
          "$mod, E, exec, dolphin"
          "$mod, F, exec, firefox"
          "$mod + SHIFT, F, exec, firefox -private-window"
        ];
        bindl = [
          # the doc say we shouldn't call dpms directly from a keybind, so I used hyprctl
          "$mod, F12, exec, hyprctl dispatch dpms on"
        ];
      };
    };
  };
}
