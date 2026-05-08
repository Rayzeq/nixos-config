{ lib, hmConfig, ... }: {
  imports = lib.import [ ../../config/system ];

  system.system.stateVersion = "23.05";

  hypr.land.settings.monitor = [ "e-DP1, 1920x1080@60, 0x0, 1" ];
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
  hm.programs.firefox.configPath =
    if hmConfig.home.stateVersion < "26.05" then
      ".mozilla/firefox"
    else
      lib.warn "Remove this! stateVersion is high enough for this is not needed anymore" { };
}
