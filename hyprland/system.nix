{ pkgs, ... }:
{
  services.blueman.enable = true;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    pavucontrol
    rofi
    grimblast
    swaynotificationcenter
    kdePackages.polkit-kde-agent-1
    wl-clipboard
    blueman
    darkman
    networkmanagerapplet
  ];
}
