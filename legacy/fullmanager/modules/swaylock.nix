{ home-manager, lib, pkgs, config, ... }:
let
  cfg = config.swaylock;

  swaylockOptions = (import "${home-manager}/modules/programs/swaylock.nix" {
    inherit lib pkgs;
    config = { };
  }).options.programs.swaylock;
in
{
  options.swaylock = {
    inherit (swaylockOptions) enable package settings;
  };

  config = lib.mkIf cfg.enable {
    hm.programs.swaylock = cfg;
    system.security.pam.services.swaylock = { };
  };
}
