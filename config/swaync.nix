{ lib, globals, ... }: {
  swaync = {
    enable = lib.mkDefault true;

    style = ''
      .notification {
        background: ${globals.overlay-background};
      }

      .notification.low {
        background: mix(rgba(179, 235, 242, 0.7), ${globals.overlay-background}, 0.5);
      }

      .notification.critical {
        background: mix(rgba(255, 116, 108, 0.7), ${globals.overlay-background}, 0.5);
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
