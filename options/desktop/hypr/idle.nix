{ home-manager, lib, config, ... }:
let
  inherit (lib) mkOption mkIf mkMerge types;
  cfg = config.hypr.idle;

  hypridleOptions = lib.getOptions "${home-manager}/modules/services/hypridle.nix";

  listenerModule = types.submodule {
    options = {
      timeout = mkOption {
        type = types.int;
        example = 60;
        description = ''
          Idle time in seconds.
        '';
      };
      on-timeout = mkOption {
        type = with types; nullOr str;
        default = null;
        example = "brightnessctl -s set 10";
        description = ''
          Command to run when timeout has passed.
        '';
      };
      on-resume = mkOption {
        type = with types; nullOr str;
        default = null;
        example = "brightnessctl -r";
        description = ''
          Command to run when activity is detected after timeout has fired.
        '';
      };
      ignore-inhibit = mkOption {
        type = types.bool;
        default = false;
        example = true;
        description = ''
          Ignore idle inhibitors (of all types) for this rule.
        '';
      };
    };
  };
  eventType = msg: mkOption {
    type = with types; nullOr str;
    default = null;
    description = ''
      Command to run ${msg}.
    '';
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
      default = "auto";
      example = "lock-notify";
      description = ''
        This option is used to make sure hypridle can perform certain tasks before the system goes to sleep.
        Values:
          - disable: disables sleep inhibition.
          - normal: makes the system wait until hypridle launched `events.before-sleep`.
          - auto: selects either `normal` or `lock-notify` depending on whether hypridle detects if you want to launch hyprlock before sleep.
          - lock-notify: makes your system wait until the session gets locked by a lock screen app. This works with all wayland session-lock apps.
      '';
    };

    events = {
      lock = eventType "when receiving a dbus lock event (e.g. `loginctl lock-session`)";
      unlock = eventType "when receiving a dbus unlock event (e.g. `loginctl unlock-session`)";
      on-lock = eventType "when the session gets locked by a lock screen app";
      on-unlock = eventType "when the session gets unlocked by a lock screen app";
      before-sleep = eventType "before sleeping";
      after-sleep = eventType "after resuming from sleep";
    };

    listeners = mkOption {
      type = types.listOf listenerModule;
    };
  };

  config.hm.services.hypridle = mkIf cfg.enable {
    inherit (cfg) enable package;

    settings = mkMerge ([
      {
        general.inhibit_sleep = inhibitSleepOptions.${cfg.inhibit-sleep};
        listener = map
          (listener: {
            inherit (listener) timeout;
            on-timeout = mkIf (listener.on-timeout != null) listener.on-timeout;
            on-resume = mkIf (listener.on-resume != null) listener.on-resume;
            ignore_inhibit = listener.ignore-inhibit;
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
