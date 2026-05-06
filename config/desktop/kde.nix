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
    ark
    gwenview
    okular
    dolphin
    dolphin-plugins
    ffmpegthumbs
    skanpage
  ];
  system.environment.systemPackages = [ pkgs.kdePackages.kio-admin ];
}
