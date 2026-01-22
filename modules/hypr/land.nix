{ home-manager, lib, config, ... }:
let
  cfg = config.hypr.land;

  hyprlandOptions = (lib.getOptions "${home-manager}/modules/services/window-managers/hyprland.nix").hyprland;
in
{
  options.hypr.land = {
    inherit (hyprlandOptions) enable package settings;
  };

  config = lib.mkIf cfg.enable {
    system.programs.hyprland = {
      inherit (cfg) enable package;
    };
    hm.wayland.windowManager.hyprland = {
      inherit (cfg) enable package settings;
    };
  };
}
