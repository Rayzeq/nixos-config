{ pkgs, ... }:
{
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [
    pavucontrol
    grimblast
    blueman
    networkmanagerapplet
  ];
}
