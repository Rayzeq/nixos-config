{ config, hostname, ... }: {
  hypr.land.settings.monitor = [ "e-DP1, 1920x1080@60, 0x0, 1" ];
  hm =
    if config.stateVersion.${hostname} < "26.05" then
      {
        gtk.gtk4.theme = null;
        programs.git.signing.format = null;
      }
    else builtins.warn "Remove this! stateVersion is high enough for this is not needed anymore" { };
}
