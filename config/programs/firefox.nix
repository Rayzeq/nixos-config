{
  hm.programs.firefox = {
    enable = true;

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
        "network.trr.uri" = "https://dns10.quad9.net/dns-query";
        # Used by Firefox to differenciate between the default providers it offers and a user-given provider
        "network.trr.custom_uri" = "https://dns10.quad9.net/dns-query";
        "network.trr.display_fallback_warning" = true;
      } // {
        # 3 is restore, 1 is homepage (Firefox default)
        "browser.startup.page" = 3;
        "browser.tabs.inTitlebar" = 0;

        # 1 is force enable, 2 is automatic (usually enabled only in flatpaks and snaps)
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        # "widget.use-xdg-desktop-portal.mime-handler" = 2;
        # "widget.use-xdg-desktop-portal.native-messaging" = 2;
        "widget.use-xdg-desktop-portal.settings" = 1;
        # "widget.use-xdg-desktop-portal.location" = 2;
        # "widget.use-xdg-desktop-portal.open-uri" = 2;
      };
    };
  };
}
