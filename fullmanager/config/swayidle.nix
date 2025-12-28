{ pkgs, ... }: {
  swayidle = {
    enable = true;

    timeouts = [
      {
        timeout = 295;
        command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
        resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -r";
      }
      { timeout = 300; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
      {
        timeout = 600;
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
      {
        timeout = 1200;
        command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
      }
    ];
    events = {
      lock = "${pkgs.swaylock-effects}/bin/swaylock -f";
      before-sleep = "${pkgs.swaylock-effects}/bin/swaylock -f";
    };
  };
}
