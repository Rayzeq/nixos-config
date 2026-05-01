{ pkgs, lib, config, ... }:
let
  rofi-clipboard = pkgs.writeScript "rofi-clipboard" ''
    selection=$(${config.cliphist.package}/bin/cliphist list | ${config.rofi.command.clipboard})
    if [ ! -z "$selection" ]; then
      printf "$selection" | ${config.cliphist.package}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
    fi 
  '';
in
{
  hypr.land = {
    enable = true;

    settings = {
      # primary monitor is in per-host config
      monitor = [ ", preferred, auto, 1" ];

      general = {
        gaps_in = 0;
        gaps_out = 0;
        "col.active_border" = "rgba(ff00ffee) rgba(00ff99ee) 45deg";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        key_press_enables_dpms = true;
        focus_on_activate = true;
        allow_session_lock_restore = true;
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
      device = {
        name = "synps/2-synaptics-touchpad";
        sensitivity = 0;
      };

      gesture = [
        "3, horizontal, workspace"
      ];

      gestures = {
        workspace_swipe_cancel_ratio = 0.3;
        workspace_swipe_direction_lock = false;
        workspace_swipe_forever = true;
      };

      decoration = {
        rounding = 10;
        blur = {
          passes = 3;
          size = 5;
        };
      };

      windowrule = [
        "match:class .*, idle_inhibit fullscreen"
        "match:class org.freedesktop.impl.portal.desktop.kde, float on"
        "match:initial_title Picture-in-Picture, float on, pin on"
      ];

      layerrule = [
        "match:namespace rofi|swaync-notification-window|wleave, blur on, ignore_alpha 0"

        "match:namespace selection, no_anim on"
      ];

      "$mod" = "SUPER";
      bind = [
        "$mod, F4, killactive"
        "$mod, W, togglefloating"
        "$mod, X, pin"
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
        "$mod + ALT_L + CONTROL_L, LEFT, movetoworkspace, -1"
        "$mod + ALT_L + CONTROL_L, RIGHT, movetoworkspace, +1"

        "$mod + ALT_L, LEFT, workspace, -1"
        "$mod + ALT_L, RIGHT, workspace, +1"

        "$mod, S, exec, ${config.sublime-text.package}/bin/subl"
        "$mod + SHIFT, S, exec, ${config.kitty.package}/bin/kitty sudo -EH ${config.sublime-text.package}/bin/subl"
        "$mod + CONTROL_L, S, exec, ${config.sublime-text.package}/bin/subl --new-window"

        "$mod, K, exec, ${config.kitty.package}/bin/kitty"
        "$mod, D, exec, ${config.discord.finalPackage}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland"

        "$mod, MULTI_KEY, exec, ${pkgs.grimblast}/bin/grimblast copy area"
        "$mod + CONTROL_L, MULTI_KEY, exec, ${pkgs.grimblast}/bin/grimblast --freeze copy area"
        "$mod + SHIFT, MULTI_KEY, exec, ${pkgs.grimblast}/bin/grimblast copy screen"

        ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SOURCE@ toggle"
      ];
      bindle = [
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 1%-"
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 1%+"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"
      ];
      bindl = [
        ", XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
      ];
      bindr = [
        "$mod, SUPER_L, exec, ${pkgs.procps}/bin/pkill -x rofi || ${config.rofi.command.launcher}"
        "$mod, V, exec, ${rofi-clipboard}"

        "$mod, L, exec, ${pkgs.procps}/bin/pkill -x .wleave-wrapped || ${config.wleave.package}/bin/wleave"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
