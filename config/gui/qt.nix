{ pkgs, ... }: {
  hm.qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "Breeze";
  };
}
