{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      darkman = (
        let
          version = "1.5.5-beta";
          src = prev.fetchFromGitLab {
            owner = "WhyNotHugo";
            repo = "darkman";
            rev = "7cc8c0fa";
            sha256 = "sha256-ByhoGIuYhNOj8D/iTh2ALzEzCKOHpT+8WhdEjgogaRI=";
          };
        in
        (prev.darkman.override {
          buildGoModule = args: prev.buildGoModule (args // {
            inherit src version;
            vendorHash = "sha256-xEPmNnaDwFU4l2G4cMvtNeQ9KneF5g9ViQSFrDkrafY=";
          });
        })
      );
    })
  ];

  services.blueman.enable = true;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    pavucontrol
    rofi-wayland
    grimblast
    swaynotificationcenter
    libsForQt5.polkit-kde-agent
    wl-clipboard
    blueman
    brightnessctl
    darkman
    networkmanagerapplet
  ];
}
