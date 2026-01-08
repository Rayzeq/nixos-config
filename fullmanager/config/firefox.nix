{ lib, ... }: {
  firefox = {
    enable = lib.mkDefault true;

    restore-session = true;
    custom-titlebar = false;
    dns-over-https = {
      enable = true;
      provider = "https://dns10.quad9.net/dns-query";
      fallback-warning = true;
    };
    xdg-portals = {
      file-picker = true;
      settings = true;
    };
  };
}

