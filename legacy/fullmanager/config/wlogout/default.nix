{ pkgs, lib, ... }:
let
  background-color = "rgba(0, 0, 0, 0.8)";
  background-color-active = "rgba(176, 165, 255, 0.8)";
  background-color-hover = "rgba(114, 211, 254, 0.8)";

  border-radius = "40";
  border-radius-hover = "20";
  margin = "30";
in
{
  wlogout = {
    enable = lib.mkDefault true;

    layout = [
      {
        label = "lock";
        action = "${pkgs.systemd}/bin/loginctl lock-session";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "${pkgs.systemd}/bin/systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "logout";
        action = "${pkgs.hyprland}/bin/hyprctl dispatch exit";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "shutdown";
        action = "${pkgs.systemd}/bin/systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "suspend";
        action = "${pkgs.systemd}/bin/systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "${pkgs.systemd}/bin/systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];

    style = ''
      window {
        background: transparent;
      }

      button {
        border: none;
        border-radius: 0;
        outline: none;

        color: white;
        font-size: 30px;
        font-weight: bold;
        text-shadow: none;

        background-color: ${background-color};
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;

        animation: gradient_f 20s ease-in infinite;
      }

      button:focus {
        background-color: ${background-color-active};
        background-size: 30%;
      }

      button:hover {
        background-color: ${background-color-hover};
        background-size: 35%;
        border-radius: ${border-radius-hover}px;

        transition: all 0.3s cubic-bezier(.55,0.0,.28,1.682);
      }

      #lock {
        background-image: image(url("${./lock.png}"));
        border-radius: ${border-radius}px 0px 0px 0px;
      }

      #logout {
        background-image: image(url("${./logout.png}"));
      }

      #suspend {
        background-image: image(url("${./suspend.png}"));
        border-radius: 0px ${border-radius}px 0px 0px;
      }

      #hibernate {
        background-image: image(url("${./hibernate.png}"));
        border-radius: 0px 0px 0px ${border-radius}px;
      }

      #shutdown {
        background-image: image(url("${./shutdown.png}"));
      }

      #reboot {
        background-image: image(url("${./reboot.png}"));
        border-radius: 0px 0px ${border-radius}px 0px;
      }

      button:hover#lock {
        border-radius: ${border-radius-hover}px;
        margin: 0px ${margin}px ${margin}px 0px;
      }

      button:hover#logout {
        margin: 0px ${margin}px ${margin}px ${margin}px;
      }

      button:hover#suspend {
        border-radius: ${border-radius-hover}px;
        margin: 0px 0px ${margin}px ${margin}px;
      }

      button:hover#hibernate {
        border-radius: ${border-radius-hover}px;
        margin: ${margin}px 30px 0px 0px;
      }

      button:hover#shutdown {
        margin: ${margin}px ${margin}px 0px ${margin}px;
      }

      button:hover#reboot {
        border-radius: ${border-radius-hover}px;
        margin: ${margin}px 0px 0px ${margin}px;
      }
    '';
  };
}
