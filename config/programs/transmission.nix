{ pkgs, config, username, ... }:
let
  icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/transmission/transmission/main/icons/hicolor_apps_scalable_transmission.svg";
    hash = "sha256-Pk1n40jF+ZSYvN/ddgjsPkptQqV6dBjKJcS2NIohCTo=";
  };
  desktopFile = pkgs.writeTextDir "share/applications/transmission-web.desktop" ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Transmission
    GenericName=BitTorrent Client
    Comment=Open Transmission Web UI
    Exec=${pkgs.xdg-utils}/bin/xdg-open http://127.0.0.1:9091/
    Icon=${icon}
    Terminal=false
    Categories=Network;FileTransfer;P2P;
    Keywords=bittorrent;torrent;web;ui;
    StartupNotify=true
  '';
in
{
  system.services.transmission = {
    enable = true;
    package =
      if config.stateVersion.${username} < "25.11" then
        pkgs.transmission_4
      else builtins.warn "Remove this! stateVersion is high enough for this is not needed anymore" { };
    webHome = pkgs.flood-for-transmission;
  };
  user.extraGroups = [ "transmission" ];
  hm.home.packages = [ desktopFile ];
}
