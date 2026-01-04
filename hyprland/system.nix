{ pkgs, ... }:
{
  services.blueman.enable = true;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    pavucontrol
    grimblast
    kdePackages.polkit-kde-agent-1
    wl-clipboard
    blueman
    networkmanagerapplet
  ];
}
