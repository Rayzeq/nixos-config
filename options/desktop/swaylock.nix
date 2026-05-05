{ home-manager, lib, config, ... }:
let
  cfg = config.swaylock;

  swaylockOptions = lib.getOptions "${home-manager}/modules/programs/swaylock.nix";
in
{
  options.swaylock = {
    inherit (swaylockOptions) package settings;
    enable = lib.mkEnableOption "Swaylock";
  };

  config = lib.mkIf cfg.enable {
    hm.programs.swaylock = cfg;
    system.security.pam.services.swaylock = { };
  };
}
