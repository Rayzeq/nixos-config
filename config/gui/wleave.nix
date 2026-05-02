{ pkgs, config, ... }:
let
  icons = "${pkgs.wleave}/share/wleave/icons";

  background = config.globals.theme.overlay.background;
  background-active = "rgba(176, 165, 255, ${toString background.a})";
  background-hover = "rgba(114, 211, 254, ${toString background.a})";

  border-radius = "40";
  border-radius-hover = "20";
  margin = "30";
in
{
  wleave = {
    enable = true;

    settings = {
      no-version-info = true;
      column-spacing = 0;
      row-spacing = 0;

      buttons = [
        {
          label = "lock";
          action = "${pkgs.systemd}/bin/loginctl lock-session";
          text = "Lock";
          keybind = "l";
          icon = "${icons}/lock.svg";
        }
        {
          label = "suspend";
          action = "${pkgs.systemd}/bin/systemctl suspend";
          text = "Suspend";
          keybind = "u";
          icon = "${icons}/suspend.svg";
        }
        {
          label = "shutdown";
          action = ''${pkgs.hyprshutdown}/bin/hyprshutdown -t "Shutting down..." --post-cmd "${pkgs.systemd}/bin/systemctl poweroff"'';
          text = "Shutdown";
          keybind = "s";
          icon = "${icons}/shutdown.svg";
        }
        {
          label = "logout";
          action = ''${pkgs.hyprshutdown}/bin/hyprshutdown -t "Logging out..."'';
          text = "Logout";
          keybind = "e";
          icon = "${icons}/logout.svg";
        }
        {
          label = "hibernate";
          action = "${pkgs.systemd}/bin/systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
          icon = "${icons}/hibernate.svg";
        }
        {
          label = "reboot";
          action = ''${pkgs.hyprshutdown}/bin/hyprshutdown -t "Rebooting..." --post-cmd "${pkgs.systemd}/bin/systemctl reboot"'';
          text = "Reboot";
          keybind = "r";
          icon = "${icons}/reboot.svg";
        }
      ];
    };

    style = ''
      window {
        background: transparent;
      }

      button {
        border-radius: 0px;
        font-size: 30px;
        background-color: ${background.css};
        transition: all 0.3s ease;
      }

      button:focus {
        background-color: ${background-active};
      }

      button:hover {
        background-color: ${background-hover};
        border-radius: ${border-radius-hover}px;
      }

      #lock {
        color: #ffe8b6;
        border-radius: ${border-radius}px 0px 0px 0px;
      }

      #suspend {
        color: #caaff9;
      }

      #shutdown {
        color: #ff8d8d;
        border-radius: 0px ${border-radius}px 0px 0px;
      }

      #logout {
        color: #ffcca8;
        border-radius: 0px 0px 0px ${border-radius}px;
      }

      #hibernate {
        color: #a8c0ff;
      }

      #reboot {
        color: #84ffaa;
        border-radius: 0px 0px ${border-radius}px 0px;
      }

      #lock:hover {
        margin: 0px ${margin}px ${margin}px 0px;
      }

      #suspend:hover {
        margin: 0px ${margin}px ${margin}px ${margin}px;
      }

      #shutdown:hover {
        margin: 0px 0px ${margin}px ${margin}px;
      }

      #logout:hover {
        margin: ${margin}px ${margin}px 0px 0px;
      }

      #hibernate:hover {
        margin: ${margin}px ${margin}px 0px ${margin}px;
      }

      #reboot:hover {
        margin: ${margin}px 0px 0px ${margin}px;
      }
    '';
  };
}
