{ pkgs, ... }: {
  enable = true;

  timeouts = [
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
  events = [
    { event = "lock"; command = "${pkgs.procps}/bin/pgrep swaylock || ${pkgs.swaylock-effects}/bin/swaylock -f"; }
    # { event = "before-sleep"; command = "${pkgs.procps}/bin/pgrep swaylock || ${pkgs.swaylock-effects}/bin/swaylock -f"; }
  ];
}
