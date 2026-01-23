{ pkgs, lib, ... }:
{
  home-manager.users.zacharie = { config, ... }: {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
      size = 24;
    };

    gtk = {
      enable = true;

      font = {
        name = "Noto Sans";
        size = 10;
      };
      cursorTheme = {
        name = "breeze_cursors";
        size = 24;
      };
      iconTheme = {
        package = pkgs.kdePackages.breeze-icons;
        name = "breeze-dark";
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "kde";
      style.name = "Breeze";
    };

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
          "$mod, MULTI_KEY, exec, grimblast copy area"
          "$mod + CONTROL_L, MULTI_KEY, exec, grimblast --freeze copy area"
          "$mod + SHIFT, MULTI_KEY, exec, grimblast copy screen"

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
