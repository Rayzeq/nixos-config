{ lib, hmConfig, ... }: {
  imports = lib.import [ ../../config/system ];

  system.system.stateVersion = "23.05";

  hypr.land.settings = {
    monitor = [{ output = "e-DP1"; mode = "1920x1080@60"; position = "0x0"; scale = 1; }];
    device = {
      name = "synps/2-synaptics-touchpad";
      sensitivity = 0;
    };
  };
  hm.wayland.windowManager.hyprland.configType =
    if hmConfig.home.stateVersion < "26.05" then
      "lua"
    else
      lib.warn "Remove this! stateVersion is high enough for this is not needed anymore" { };
  hm.gtk.gtk4.theme =
    if hmConfig.home.stateVersion < "26.05" then
      null
    else
      lib.warn "Remove this! stateVersion is high enough for this is not needed anymore" { };
  hm.programs.git.signing.format =
    if hmConfig.home.stateVersion < "26.05" then
      null
    else
      lib.warn "Remove this! stateVersion is high enough for this is not needed anymore" { };
}
