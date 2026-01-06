{ pkgs, ... }:
{
  services.blueman.enable = true;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    pavucontrol
    grimblast
    wl-clipboard
    blueman
    networkmanagerapplet
  ];
}
