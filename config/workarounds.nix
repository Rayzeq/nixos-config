{ pkgs, ... }: {
  hm = {
    # This is needed for dolphin to detect applications outside of plasma6.
    # This is technically expected behavior and (likely) won't be fixed from KDE's side,
    # but it might be from nixos's side
    # See https://github.com/NixOS/nixpkgs/issues/409986
    # and https://specifications.freedesktop.org/menu/latest/paths.html
    # Possible solutions:
    #   - keep plasma's file (what we're doing now)
    #   - use another DE's file
    #   - create our own menu file
    xdg.configFile."menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  };
}
