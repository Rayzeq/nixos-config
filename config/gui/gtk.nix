{ pkgs, config, ... }: {
  hm.gtk = {
    enable = true;
    font = {
      inherit (builtins.head config.fonts.sans-serif) package name;
      size = 10;
    };
    iconTheme = {
      package = pkgs.kdePackages.breeze-icons;
      name = "breeze-dark";
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
