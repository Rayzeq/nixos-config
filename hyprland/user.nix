{ pkgs, unstable, lib, home-manager, ... }:
let combinedConfig = import ../generator/default.nix { inherit pkgs unstable lib; };
in lib.mkMerge [
  combinedConfig.system
  {
    home-manager.users.zacharie = { config, ... }: lib.mkMerge [
      combinedConfig.user
      {
        xdg.configFile."rofi/clipboard.sh" = {
          source = ./rofi/clipboard.sh;
          executable = true;
        };
        xdg.configFile."rofi/style.rasi".source = ./rofi/style.rasi;
        xdg.configFile."rofi/launcher.rasi".source = ./rofi/launcher.rasi;
        xdg.configFile."rofi/clipboard.rasi".source = ./rofi/clipboard.rasi;

        home.pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          package = pkgs.libsForQt5.breeze-qt5;
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
            package = pkgs.libsForQt5.breeze-icons;
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
          platformTheme = "kde";
          style.name = "Breeze";
        };

        services.playerctld.enable = true;
        services.cliphist.enable = true;
        wayland.windowManager.hyprland = {
          enable = true;

          settings = {
            exec-once = [
              "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1"
              "eww open statusbar && ( nm-applet & blueman-applet & discord --start-minimized & )"
              "hyprpaper"
              "swaync"
              "[workspace special silent;noanim] kitty"
            ];
            monitor = [ "e-DP1,1920x1080@60,0x0,1" ",preferred,auto,1" ];

            general = {
              gaps_in = 0;
              gaps_out = 0;
              "col.active_border" = "rgba(ff00ffee) rgba(00ff99ee) 45deg";
            };

            misc = {
              force_default_wallpaper = 0;
              focus_on_activate = true;
            };

            input = {
              kb_layout = "fr";
              kb_variant = "oss";
              kb_options = "compose:prsc";
              numlock_by_default = true;

              follow_mouse = 1;
              sensitivity = -0.3;

              touchpad = {
                natural_scroll = "yes";
              };
            };
            "device:synps/2-synaptics-touchpad" = {
              sensitivity = 0;
            };

            gestures = {
              workspace_swipe = true;
              workspace_swipe_cancel_ratio = 0.3;
              workspace_swipe_direction_lock = false;
              workspace_swipe_forever = true;
            };

            decoration = {
              rounding = 10;
              blur = {
                size = 3;
              };
            };

            "$mod" = "SUPER";
            bind = [
              "$mod, DELETE, exit"
              "$mod, L, exec, pkill -x wlogout || wlogout -p layer-shell"
              "$mod, F4, killactive"
              "$mod, MULTI_KEY, exec, grimblast copy area"
              "$mod + SHIFT, MULTI_KEY, exec, grimblast copy screen"
              "$mod, V, exec, ${config.home.homeDirectory}/${config.xdg.configFile."rofi/clipboard.sh".target}"

              "$mod, K, exec, kitty"
              "$mod, E, exec, dolphin"
              "$mod, D, exec, discord"
              "$mod, F, exec, firefox"

              "$mod, W, togglefloating"
              "$mod, PRIOR, fullscreen, 1"
              "$mod, KP_End, movetoworkspace, 1"
              "$mod, KP_Down, movetoworkspace, 2"
              "$mod, KP_Next, movetoworkspace, 3"
              "$mod, KP_Left, movetoworkspace, 4"
              "$mod, KP_Begin, movetoworkspace, 5"
              "$mod, KP_Right, movetoworkspace, 6"
              "$mod, KP_Home, movetoworkspace, 7"
              "$mod, KP_Up, movetoworkspace, 8"
              "$mod, KP_Prior, movetoworkspace, 9"

              "$mod + ALT_L, LEFT, workspace, -1"
              "$mod + ALT_L, RIGHT, workspace, +1"
              "$mod, S, togglespecialworkspace"

              ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
              ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
            ];
            bindle = [
              ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 1%-"
              ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 1%+"
              ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
              ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
            ];
            bindl = [
              # the doc say we shouldn't call dpms directly from a keybind, so I used hyprctl
              "$mod, F12, exec, hyprctl dispatch dpms on"

              ", XF86AudioPause, exec, playerctl -a pause"
              ", XF86AudioPlay, exec, playerctl -a play"
            ];
            bindr = [
              "$mod, SUPER_L, exec, pkill -x rofi || rofi -show drun -theme \"~/.config/rofi/launcher.rasi\""
            ];
            bindm = [
              "$mod, mouse:272, movewindow"
              "$mod, mouse:273, resizewindow"
            ];

            layerrule = [
              "ignorezero, rofi"
              "ignorezero, waybar"
              "blur, rofi"
              "blur, waybar"
            ];
          };
        };

        services.darkman = {
          enable = true;
          package = pkgs.darkman;
          settings = {
            lat = 46.6;
            lng = 1.6;
            usegeoclue = false;
          };
          darkModeScripts = {
            wallpaper = import ./darkman/dark.sh { inherit pkgs config; };
          };
          lightModeScripts = {
            wallpaper = import ./darkman/light.sh { inherit pkgs config; };
          };
        };

        services.blueman-applet.enable = true;
      }
    ];
  }
]
