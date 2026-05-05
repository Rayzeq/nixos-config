{ pkgs, ... }: {
  system = {
    # Don't know what's useful or not here

    # Enable CUPS to print documents.
    services.printing = {
      enable = true;
      drivers = with pkgs; [ epson-escpr epson-escpr2 gutenprint gutenprintBin ];
    };

    # Auto-discovery of printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Enable scan
    hardware.sane.enable = true;
  };
  user.extraGroups = [ "scanner" "lp" ];
}
