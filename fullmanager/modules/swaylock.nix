{ lib, pkgs, config, ... }:
let
  cfg = config.swaylock;

  swaylockOptions = (import <home-manager/modules/programs/swaylock.nix> {
    inherit lib pkgs;
    config = { };
  }).options.programs.swaylock;
in
{
  options.swaylock = {
    enable = swaylockOptions.enable;
    package = swaylockOptions.package;

    settings = swaylockOptions.settings;
  };

  config = lib.mkIf cfg.enable {
    hm.programs.swaylock = {
      enable = cfg.enable;
      package = cfg.package;
      settings = cfg.settings;
    };
    system.security.pam.services.swaylock = { };
  };
}
