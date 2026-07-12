{ pkgs, lib, config, hmConfig, ... }:
{
  hypr.land = {
    enable = true;

    settings = {
      general = {
        gaps_in = 0;
        gaps_out = 0;
        col.active_border = { colors = [ "rgba(ff00ffee)" "rgba(00ff99ee)" ]; angle = 45; };
      };

      decoration = {
        rounding = 10;
        blur = {
          passes = 3;
          size = 5;
        };
      };

      input = {
        kb_layout = "fr";
        kb_variant = "oss";
        kb_options = "compose:prsc";
        numlock_by_default = true;

        sensitivity = -0.3;
        follow_mouse = 1;
        focus_on_close = 1;
        float_switch_override_focus = 2;

        touchpad = {
          natural_scroll = true;
        };
      };

      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];

      gestures = {
        workspace_swipe_cancel_ratio = 0.3;
        workspace_swipe_direction_lock = false;
        workspace_swipe_forever = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        key_press_enables_dpms = true;
        focus_on_activate = true;
        allow_session_lock_restore = true;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      # primary monitor is in per-host config
      monitor = [{ output = ""; mode = "preferred"; position = "auto"; scale = 1; }];

      bind = with config.lib.hyprland.dispatchers; [
        [ "SUPER + mouse:272" window.drag ]
        [ "SUPER + mouse:273" window.resize ]
        [ "SUPER + F4" window.close ]
        [ "SUPER + W" (window.float "toggle") ]
        [ "SUPER + X" (window.pin "toggle") ]
        [ "SUPER + PRIOR" (window.fullscreen "maximized" "toggle") ]
        [ "SUPER + SHIFT + PRIOR" (window.fullscreen "fullscreen" "toggle") ]

        [ "SUPER + KP_End" (window.move.workspace 1) ]
        [ "SUPER + KP_Down" (window.move.workspace 2) ]
        [ "SUPER + KP_Next" (window.move.workspace 3) ]
        [ "SUPER + KP_Left" (window.move.workspace 4) ]
        [ "SUPER + KP_Begin" (window.move.workspace 5) ]
        [ "SUPER + KP_Right" (window.move.workspace 6) ]
        [ "SUPER + KP_Home" (window.move.workspace 7) ]
        [ "SUPER + KP_Up" (window.move.workspace 8) ]
        [ "SUPER + KP_Prior" (window.move.workspace 9) ]
        [ "SUPER + ALT + CONTROL + LEFT" (window.move.workspace "r-1") ]
        [ "SUPER + ALT + CONTROL + RIGHT" (window.move.workspace "r+1") ]

        [ "SUPER + ALT + LEFT" (focus.workspace "r-1") ]
        [ "SUPER + ALT + RIGHT" (focus.workspace "r+1") ]

        [ "SUPER + S" (exec "${config.sublime-text.package}/bin/subl") ]
        [ "SUPER + SHIFT + S" (exec "${config.kitty.package}/bin/kitty sudo -EH ${config.sublime-text.package}/bin/subl") ]
        [ "SUPER + CONTROL + S" (exec "${config.sublime-text.package}/bin/subl --new-window") ]

        [ "SUPER + F" (exec "${pkgs.firefox}/bin/firefox") ]
        [ "SUPER + SHIFT + F" (exec "${pkgs.firefox}/bin/firefox -private-window") ]

        [ "SUPER + K" (exec "${config.kitty.package}/bin/kitty") ]
        [ "SUPER + E" (exec "${pkgs.kdePackages.dolphin}/bin/dolphin") ]

        [ "SUPER + MULTI_KEY" (exec "${pkgs.grimblast}/bin/grimblast copy area") ]
        [ "SUPER + CONTROL + MULTI_KEY" (exec "${pkgs.grimblast}/bin/grimblast --freeze copy area") ]
        [ "SUPER + SHIFT + MULTI_KEY" (exec "${pkgs.grimblast}/bin/grimblast copy screen") ]

        [ "SUPER + SUPER_L" (exec "${pkgs.procps}/bin/pkill -x rofi || ${config.rofi.command.launcher}") { release = true; } ]
        [ "SUPER + L" (exec "${pkgs.procps}/bin/pkill -x .wleave-wrapped || ${config.wleave.package}/bin/wleave") { release = true; } ]

        [ "XF86AudioMute" (exec "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ toggle") ]
        [ "XF86AudioMicMute" (exec "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SOURCE@ toggle") ]
        [ "XF86AudioPause" (exec "${pkgs.playerctl}/bin/playerctl play-pause") { locked = true; } ]
        [ "XF86AudioPlay" (exec "${pkgs.playerctl}/bin/playerctl play-pause") { locked = true; } ]
        [ "XF86AudioNext" (exec "${pkgs.playerctl}/bin/playerctl next") { locked = true; } ]
        [ "XF86AudioPrev" (exec "${pkgs.playerctl}/bin/playerctl previous") { locked = true; } ]
        [ "XF86AudioLowerVolume" (exec "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 1%-") { locked = true; repeating = true; } ]
        [ "XF86AudioRaiseVolume" (exec "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 1%+") { locked = true; repeating = true; } ]
        [ "XF86MonBrightnessDown" (exec "${pkgs.brightnessctl}/bin/brightnessctl set 5%-") { locked = true; repeating = true; } ]
        [ "XF86MonBrightnessUp" (exec "${pkgs.brightnessctl}/bin/brightnessctl set +5%") { locked = true; repeating = true; } ]
      ];

      window_rule = [
        { match.class = ".*"; idle_inhibit = "fullscreen"; }
        { match.class = "org.freedesktop.impl.portal.desktop.kde"; float = true; }
        { match.initial_title = "Picture-in-Picture"; float = true; pin = true; focus_on_activate = false; }
      ];
      layer_rule = [
        { match.namespace = "rofi|swaync-notification-window|wleave|quickshell"; blur = true; ignore_alpha = 0; }
        { match.namespace = "selection"; no_anim = true; }
      ];

      animation = [
        { leaf = "specialWorkspace"; enabled = true; speed = 10; bezier = "default"; style = "fade"; }
      ];
    };
  };
  hm.wayland.windowManager.hyprland.settings = {
    on = {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''function ()
          hl.exec_cmd("/mnt/Storage/Projects/tryfol/target/debug/tryfol && ( nm-applet & blueman-applet & discord --enable-features=UseOzonePlatform --ozone-platform=wayland --start-minimized & )")
        end'')
      ];
    };

    env = lib.mapAttrsToList (name: value: { _args = [ name "${toString value}" ]; }) (hmConfig.systemd.user.sessionVariables // hmConfig.home.sessionVariables);
  };
}
