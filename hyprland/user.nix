{ pkgs, lib, ... }:
let
  combinedConfig = import ../generator/default.nix { inherit pkgs lib; };
in
lib.mkMerge [
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

        services.playerctld.enable = true;
        services.cliphist.enable = true;
        wayland.windowManager.hyprland = {
          enable = true;

          settings = {
            exec-once = [
              "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
              "eww open statusbar && ( nm-applet & blueman-applet & discord --enable-features=UseOzonePlatform --ozone-platform=wayland --start-minimized & )"
              "hyprpaper"
              "swaync"
              "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit"
            ];
            monitor = [ "e-DP1,1920x1080@60,0x0,1" ",preferred,auto,1" ];

            env = builtins.attrValues (builtins.mapAttrs (name: value: name + "," + (toString value)) (config.systemd.user.sessionVariables // config.home.sessionVariables));

            general = {
              gaps_in = 0;
              gaps_out = 0;
              "col.active_border" = "rgba(ff00ffee) rgba(00ff99ee) 45deg";
            };

            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
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
            device = {
              name = "synps/2-synaptics-touchpad";
              sensitivity = 0;
            };

            dwindle = {
              special_scale_factor = 1;
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
              "$mod, S, exec, subl"
              "$mod + SHIFT, S, exec, kitty sudo -EH subl"
              "$mod, E, exec, dolphin"
              "$mod, D, exec, discord --enable-features=UseOzonePlatform --ozone-platform=wayland"
              "$mod, F, exec, firefox"
              "$mod + SHIFT, F, exec, firefox -private-window"

              "$mod, W, togglefloating"
              "$mod, PRIOR, fullscreen, 1"
              "$mod + SHIFT, PRIOR, fullscreen, 0"
              "$mod, KP_End, movetoworkspace, 1"
              "$mod, KP_Down, movetoworkspace, 2"
              "$mod, KP_Next, movetoworkspace, 3"
              "$mod, KP_Left, movetoworkspace, 4"
              "$mod, KP_Begin, movetoworkspace, 5"
              "$mod, KP_Right, movetoworkspace, 6"
              "$mod, KP_Home, movetoworkspace, 7"
              "$mod, KP_Up, movetoworkspace, 8"
              "$mod, KP_Prior, movetoworkspace, 9"
              "$mod + ALT_L, Q, movetoworkspace, special"

              "$mod + ALT_L, LEFT, workspace, -1"
              "$mod + ALT_L, RIGHT, workspace, +1"
              "$mod, Q, togglespecialworkspace"

              ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
              ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
            ];
            bindle = [
              ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 1%-"
              ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 1%+"
              ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
              ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"
            ];
            bindl = [
              # the doc say we shouldn't call dpms directly from a keybind, so I used hyprctl
              "$mod, F12, exec, hyprctl dispatch dpms on"

              ", XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl pause"
              ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play"
              ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
              ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
            ];
            bindr = [
              "$mod, SUPER_L, exec, pkill -x rofi || rofi -show drun -theme \"~/.config/rofi/launcher.rasi\""
            ];
            bindm = [
              "$mod, mouse:272, movewindow"
              "$mod, mouse:273, resizewindow"
            ];

            windowrulev2 = [
              "idleinhibit fullscreen, class:.*"
            ];

            layerrule = [
              "ignorezero, rofi"
              "blur, rofi"
            ];
          };
        };

        services.darkman = {
          enable = true;
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

        # services.blueman-applet.enable = true;

        # The default config, without the examples which break everything
        xdg.configFile."swaync/config.json".text = ''
          {
            "$schema": "${pkgs.swaynotificationcenter}/etc/xdg/swaync/configSchema.json",
            "positionX": "right",
            "positionY": "top",
            "layer": "overlay",
            "control-center-layer": "top",
            "layer-shell": true,
            "cssPriority": "application",
            "control-center-margin-top": 0,
            "control-center-margin-bottom": 0,
            "control-center-margin-right": 0,
            "control-center-margin-left": 0,
            "notification-2fa-action": true,
            "notification-inline-replies": true,
            "notification-icon-size": 64,
            "notification-body-image-height": 100,
            "notification-body-image-width": 200,
            "timeout": 10,
            "timeout-low": 5,
            "timeout-critical": 0,
            "fit-to-screen": true,
            "control-center-width": 500,
            "control-center-height": 600,
            "notification-window-width": 500,
            "keyboard-shortcuts": true,
            "image-visibility": "when-available",
            "transition-time": 200,
            "hide-on-clear": false,
            "hide-on-action": true,
            "script-fail-notify": true,
            "widgets": [
              "inhibitors",
              "title",
              "dnd",
              "notifications"
            ],
            "widget-config": {
              "inhibitors": {
                "text": "Inhibitors",
                "button-text": "Clear All",
                "clear-all-button": true
              },
              "title": {
                "text": "Notifications",
                "clear-all-button": true,
                "button-text": "Clear All"
              },
              "dnd": {
                "text": "Do Not Disturb"
              }
            }
          }
        '';
        xdg.configFile."swaync/style.css".text = ''
          .floating-notifications .notification,
          .floating-notifications .notification-content {
            box-shadow: none;
          }

          .floating-notifications .notification-default-action,
          .floating-notifications .notification-action {
            border: none;
            background-color: rgba(0, 0, 0, 0.8);
          }

          .floating-notifications .notification-default-action:not(:only-child) {
            border-bottom: 1px solid gray;
          }

          .floating-notifications .notification-action {
            border-right: 1px solid gray;
          }

          .floating-notifications .notification-action:last-child {
            border-right: none;
          }

          .floating-notifications .notification-action:hover {
            color: black;
            background: rgba(114, 211, 254, 0.9);
          }
        '';
      }
    ];
  }
]
