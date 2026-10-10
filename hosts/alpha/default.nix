{ lib, systemConfig, hmConfig, ... }: {
  imports = lib.import [ ../../config/system ];

  system.system.stateVersion = "23.05";

  # The Ethernet chip/driver is bugged and needs that driver to work
  system.boot = {
    extraModulePackages = [ systemConfig.boot.kernelPackages.r8168 ];
    blacklistedKernelModules = [ "r8169" ];
  };

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
