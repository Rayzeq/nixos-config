{ pkgs, ... }: {
  hm.xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland kdePackages.xdg-desktop-portal-kde ];
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
  # Needed for gtk3 applications (notably sublime text) to use portals
  # it's technically a debug flag but who cares
  hm.systemd.user.sessionVariables.GTK_USE_PORTAL = "1";
}
