{ pkgs, ... }:
{
  imports = [ ./hyprland/user.nix ];

  home-manager.users.root = {
    imports = [ ./new ];
    home.stateVersion = "23.05";
  };

  home-manager.users.zacharie = {
    imports = [ ./new ];
    home.stateVersion = "23.05";

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
