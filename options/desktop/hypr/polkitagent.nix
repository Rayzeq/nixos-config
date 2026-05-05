{ home-manager, lib, config, ... }:
let
  cfg = config.hypr.polkitagent;

  hyprpolkitagentOptions = lib.getOptions "${home-manager}/modules/services/hyprpolkitagent.nix";
in
{
  options.hypr.polkitagent = {
    inherit (hyprpolkitagentOptions) enable package;
  };

  config.hm.services.hyprpolkitagent = lib.mkIf cfg.enable cfg;
}
