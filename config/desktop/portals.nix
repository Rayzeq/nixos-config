{ pkgs, ... }: {
  hm.xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
    config.hyprland = {
      default = [
        "hyprland"
        "kde"
      ];
      "org.freedesktop.impl.portal.Settings" = [
        "darkman"
      ];
    };
  };
}
