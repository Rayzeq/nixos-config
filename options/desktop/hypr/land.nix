{ nixpkgs, home-manager, lib, config, ... }:
let
  cfg = config.hypr.land;

  hyprlandOptions = (lib.getOptions "${home-manager}/modules/services/window-managers/hyprland.nix").hyprland;
  hyprlandSystemOptions = (lib.getOptions "${nixpkgs}/nixos/modules/programs/wayland/hyprland.nix");
in
{
  options.hypr.land = {
    inherit (hyprlandOptions) enable package;
    inherit (hyprlandSystemOptions) withUWSM;
    settings = lib.defer hyprlandOptions.settings;
  };

  config = lib.mkIf cfg.enable {
    system.programs.hyprland = {
      inherit (cfg) enable package withUWSM;
    };
    hm.wayland.windowManager.hyprland = {
      inherit (cfg) enable package settings;
    } // (lib.optionalAttrs cfg.withUWSM { systemd.enable = false; });
  };
}
