{ config, pkgs, unstable, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
    ./hyprland/user.nix
  ];

  home-manager.users.root = {
    _module.args.unstable = unstable;
    imports = [ ./new ];
    home.stateVersion = "23.05";
  };

  home-manager.users.zacharie = {
    _module.args.unstable = unstable;
    imports = [ ./new ];
    home.stateVersion = "23.05";
    home.packages = with pkgs; [ meslo-lgs-nf fira ];

    programs.git = {
      enable = true;
      userName = "Zacharie Dubrulle";
      userEmail = "dubrullezacharie@gmail.com";
      aliases = {
        forget = "!git rm -r --cached . && git add . && :";
      };
    };
  };
}
