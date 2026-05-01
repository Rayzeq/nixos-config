{ pkgs, ... }:
{
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [
    pavucontrol
    blueman
    networkmanagerapplet
  ];
}
