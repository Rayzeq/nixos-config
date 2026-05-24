{ pkgs, ... }: {
  hm.home.packages = with pkgs.kdePackages; [
    # Framework
    frameworkintegration
    kcoreaddons
    kfilemetadata
    kimageformats
    qtimageformats
    kio
    kio-admin
    kio-extras
    kdegraphics-thumbnailers

    # Apps & plugins
    kcalc
    ark
    gwenview
    okular
    dolphin
    dolphin-plugins
    ffmpegthumbs
    skanpage

    # provides kfontview
    plasma-workspace
  ];
  system.environment.systemPackages = [ pkgs.kdePackages.kio-admin ];
}
