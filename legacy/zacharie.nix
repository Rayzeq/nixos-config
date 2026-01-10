{ ... }:
{
  imports = [ ./hyprland/user.nix ];
  home-manager.useGlobalPkgs = true;

  home-manager.users.root = {
    home.stateVersion = "23.05";
  };

  home-manager.users.zacharie = {
    home.stateVersion = "23.05";
  };
}
