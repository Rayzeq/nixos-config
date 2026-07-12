{ pkgs, ... }: {
  # Mouse keybind to reset keyboard
  system.security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "${pkgs.coreutils-full}/bin/tee /sys/bus/serio/drivers/atkbd/unbind";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  hypr.land.settings.bind = [
    [ "F5" ''hl.dsp.exec_cmd("echo -n \"serio0\" | sudo ${pkgs.coreutils-full}/bin/tee /sys/bus/serio/drivers/atkbd/unbind")'' { long_press = true; locked = true; ignore_mods = true; dont_inhibit = true; submap_universal = true; } ]
  ];
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
