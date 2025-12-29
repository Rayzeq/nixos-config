{ pkgs, ... }:
{
  services.blueman.enable = true;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    pavucontrol
    rofi
    grimblast
    kdePackages.polkit-kde-agent-1
    wl-clipboard
    blueman
    networkmanagerapplet
  ];
}
