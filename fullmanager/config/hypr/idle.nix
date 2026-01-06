{ pkgs, ... }: {
  hypr.idle = {
    enable = true;

    # wait for lockscreen before sleeping
    inhibit-sleep = "lock-notify";
    events = {
      lock = "${pkgs.swaylock-effects}/bin/swaylock -f";
      before-sleep = "${pkgs.systemd}/bin/loginctl lock-session";
      after-sleep = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
    };
    listeners = [
      {
        timeout = 170; # 3 minutes minus 10 seconds
        on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
        on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
      }
      {
        timeout = 180; # 3 minutes
        on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      {
        timeout = 180; # 3 minutes
        on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd tpacpi::kbd_backlight set 0";
        on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd tpacpi::kbd_backlight";
      }
      {
        timeout = 360; # 6 minutes
        on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
      {
        timeout = 1200; # 20 minutes
        on-timeout = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
      }
    ];
  };
}
