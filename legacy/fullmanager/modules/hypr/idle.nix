{ home-manager, lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkIf mkMerge types;
  cfg = config.hypr.idle;

  hypridleOptions = (import "${home-manager}/modules/services/hypridle.nix" {
    inherit lib pkgs;
    config = { };
  }).options.services.hypridle;

  eventsModule = types.submodule {
    options = {
      lock = mkOption { type = with types; nullOr str; default = null; };
      unlock = mkOption { type = with types; nullOr str; default = null; };
      on-lock = mkOption { type = with types; nullOr str; default = null; };
      on-unlock = mkOption { type = with types; nullOr str; default = null; };
      before-sleep = mkOption { type = with types; nullOr str; default = null; };
      after-sleep = mkOption { type = with types; nullOr str; default = null; };
    };
  };

  listenerModule = types.submodule {
    options = {
      timeout = mkOption { type = types.int; };
      on-timeout = mkOption { type = with types; nullOr str; default = null; };
      on-resume = mkOption { type = with types; nullOr str; default = null; };
      ignore-inhibit = mkOption { type = with types; nullOr bool; default = null; };
    };
  };

  inhibitSleepOptions = {
    disable = 0;
    normal = 1;
    auto = 2;
    lock-notify = 3;
  };
in
{
  options.hypr.idle = {
    inherit (hypridleOptions) enable package;

    inhibit-sleep = mkOption {
      type = types.enum [ "disable" "normal" "auto" "lock-notify" ];
    };

    events = mkOption {
      type = eventsModule;
    };

    listeners = mkOption {
      type = types.listOf listenerModule;
    };
  };

  config.hm.services.hypridle = mkIf cfg.enable {
    inherit (cfg) enable package;
    settings = mkMerge ([
      (mkIf (builtins.hasAttr "inhibit-sleep" cfg) {
        general.inhibit_sleep = inhibitSleepOptions.${cfg.inhibit-sleep};
      })
      {
        listener = map
          (listener: {
            inherit (listener) timeout;
            on-timeout = mkIf (listener.on-timeout != null) listener.on-timeout;
            on-resume = mkIf (listener.on-resume != null) listener.on-resume;
            ignore_inhibit = mkIf (listener.ignore-inhibit != null) listener.ignore-inhibit;
          })
          cfg.listeners;
      }
    ] ++ (
      lib.mapAttrsToList
        (name: value:
          if value != null then
            { general."${builtins.replaceStrings ["-"] ["_"] name}_cmd" = value; }
          else { }
        )
        cfg.events
    ));
  };
}
