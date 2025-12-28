{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkEnableOption mkOption mkPackageOption mkIf;
  cfg = config.firefox;

  dohOptions = types.submodule {
    options = {
      enable = mkEnableOption "DNS over HTTPS";
      provider = mkOption {
        type = types.str;
        default = "";
        description = "Url of the provider to use.";
      };
      fallback-warning = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to show a warning when falling back to unsecure DNS.";
      };
    };
  };
  xdgPortalsOptions = types.submodule {
    options = {
      file-picker = mkOption {
        type = types.bool;
        default = false;
        description = "Force usage of XDG portals for the file pickers.";
      };
      mime-handler = mkOption {
        type = types.bool;
        default = false;
        description = "Force usage of XDG portals for the mime handler.";
      };
      native-messaging = mkOption {
        type = types.bool;
        default = false;
        description = "Force usage of XDG portals for native messaging.";
      };
      settings = mkOption {
        type = types.bool;
        default = false;
        description = "Force usage of XDG portals for settings (look-and-feel information).";
      };
      location = mkOption {
        type = types.bool;
        default = false;
        description = "Force usage of XDG portals for getting the location.";
      };
      open-uri = mkOption {
        type = types.bool;
        default = false;
        description = "Force usage of XDG portals for opening to a file.";
      };
    };
  };
in
{
  options.firefox = {
    enable = mkEnableOption "Firefox";
    package = mkPackageOption pkgs "firefox" { };

    restore-session = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to restore the previous session when opening Firefox.";
    };
    custom-titlebar = mkOption {
      type = types.bool;
      default = true;
      description = "Allows Firefox to use a custom titlebar (i.e tabs are in the titlebar).";
    };
    dns-over-https = mkOption {
      type = dohOptions;
      default = { };
      description = "DNS over HTTPS options.";
    };
    xdg-portals = mkOption {
      type = xdgPortalsOptions;
      default = { };
      description = "Force usage of XDG portals.";
    };
  };

  config.hm.programs.firefox = mkIf cfg.enable {
    enable = cfg.enable;
    package = cfg.package;
    profiles.default = {
      name = "default";
      path = "oyht42mb.default";

      # See:
      # https://searchfox.org/mozilla-release/source/modules/libpref/init/all.js
      # https://searchfox.org/mozilla-release/source/browser/app/profile/firefox.js
      # https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
      settings = {
        # DoH first, fallback to unsecure DNS
        "network.trr.mode" = 2;
        "network.trr.uri" = cfg.dns-over-https.provider;
        # Used by Firefox to differenciate between the default providers it offers and a user-given provider
        "network.trr.custom_uri" = cfg.dns-over-https.provider;
        "network.trr.display_fallback_warning" = cfg.dns-over-https.fallback-warning;
      } // {
        # 3 is restore, 1 is homepage (Firefox default)
        "browser.startup.page" = if cfg.restore-session then 3 else 1;
        "browser.tabs.inTitlebar" = if cfg.custom-titlebar then 1 else 0;

        # 1 is force enable, 2 is automatic (usually enabled only in flatpaks and snaps)
        "widget.use-xdg-desktop-portal.file-picker" = if cfg.xdg-portals.file-picker then 1 else 2;
        "widget.use-xdg-desktop-portal.mime-handler" = if cfg.xdg-portals.mime-handler then 1 else 2;
        "widget.use-xdg-desktop-portal.native-messaging" = if cfg.xdg-portals.native-messaging then 1 else 2;
        "widget.use-xdg-desktop-portal.settings" = if cfg.xdg-portals.settings then 1 else 2;
        "widget.use-xdg-desktop-portal.location" = if cfg.xdg-portals.location then 1 else 2;
        "widget.use-xdg-desktop-portal.open-uri" = if cfg.xdg-portals.open-uri then 1 else 2;
      };
    };
  };
}
