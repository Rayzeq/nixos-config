{ pkgs, ... }: {
  hm.qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "Breeze";
    # prevent home-manager from including pkgs.kdePackages.breeze.qt5
    style.package = pkgs.kdePackages.breeze;
  };
}
