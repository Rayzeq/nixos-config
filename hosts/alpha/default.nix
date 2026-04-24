{ config, username, ... }: {
  architecture = "x86_64-linux";
  stateVersion = {
    system = "23.05";
    root = "23.05";
    zacharie = "23.05";
  };

  hypr.land.settings.monitor = [ "e-DP1, 1920x1080@60, 0x0, 1" ];
  hm =
    if config.stateVersion.${username} < "26.05" then
      {
        gtk.gtk4.theme = null;
        programs.git.signing.format = null;
        programs.firefox.configPath = ".mozilla/firefox";
      }
    else builtins.warn "Remove this! stateVersion is high enough for this is not needed anymore" { };
}
