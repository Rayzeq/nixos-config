{ config, pkgs, unstable, ... }:
{
  imports = [ ./hyprland/user.nix ];

  home-manager.users.root = {
    _module.args.unstable = unstable;
    imports = [ ./new ];
    home.stateVersion = "23.05";
  };

  home-manager.users.zacharie = {
    _module.args.unstable = unstable;
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
