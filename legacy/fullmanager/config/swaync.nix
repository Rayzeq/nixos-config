{ lib, ... }: {
  swaync = {
    enable = lib.mkDefault true;

    # The default config, without the examples which break everything
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      notification-2fa-action = true;
      notification-inline-replies = true;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 500;
      control-center-height = 600;
      notification-window-width = 500;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      widgets = [
        "inhibitors"
        "title"
        "dnd"
        "notifications"
      ];
      widget-config = {
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear All";
          clear-all-button = true;
        };
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
      };
    };

    style = ''
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
  };
}
