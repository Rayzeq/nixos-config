{ pkgs, ... }:
{
  services.blueman.enable = true;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    pavucontrol
    rofi-wayland
    grimblast
    swaynotificationcenter
    kdePackages.polkit-kde-agent-1
    wl-clipboard
    blueman
    darkman
    networkmanagerapplet
  ];
}
