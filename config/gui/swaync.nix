{ lib, config, ... }:
let
  background = config.globals.theme.overlay.background;
in
{
  swaync = {
    enable = true;

    style = ''
      .notification {
        background: ${background.css};
      }

      .notification.low {
        background: mix(rgba(179, 235, 242, ${toString background.a}), ${background.css}, 0.5);
      }

      .notification.critical {
        background: mix(rgba(255, 116, 108, ${toString background.a}), ${background.css}, 0.5);
      }

      .notification:hover {
        background: rgba(0, 0, 0, 0.9);
      }

      .notification.low:hover {
        background: mix(rgba(179, 235, 242, 0.9), rgba(0, 0, 0, 0.9), 0.5);
      }

      .notification.critical:hover {
        background: mix(rgba(255, 116, 108, 0.9), rgba(0, 0, 0, 0.9), 0.5);
      }

      .notification-default-action {
        background: transparent;
      }

      .close-button {
        background: black;
      }
    '';
  };
}
