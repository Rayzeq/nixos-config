{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf types literalExpression;
  cfg = config.swayidle;

  timeoutModule = {
    options = {
      timeout = mkOption {
        type = types.ints.positive;
        example = 60;
        description = "Timeout in seconds.";
      };

      command = mkOption {
        type = types.str;
        description = "Command to run after timeout seconds of inactivity.";
      };

      resumeCommand = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "Command to run when there is activity again.";
      };
    };
  };

  eventsModule = {
    options = {
      before-sleep = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Command to run before suspending.";
      };

      after-resume = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Command to run after resuming.";
      };

      lock = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Command to run when the logind session is locked.";
      };

      unlock = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Command to run when the logind session is unlocked.";
      };
    };
  };
in
{
  options.swayidle = {
    enable = mkEnableOption "idle manager for Wayland";
    package = mkPackageOption pkgs "swayidle" { };

    timeouts = mkOption {
      type = with types; listOf (submodule timeoutModule);
      default = [ ];
      example = literalExpression ''
        [
          { timeout = 60; command = "''${pkgs.swaylock}/bin/swaylock -fF"; }
          { timeout = 90; command = "''${pkgs.systemd}/bin/systemctl suspend"; }
        ]
      '';
      description = "List of commands to run after idle timeout.";
    };

    events = mkOption {
      type =
        with types;
        (coercedTo (listOf attrs))
          (
            events:
            lib.warn
              ''
                The syntax of services.swayidle.events has changed. While it
                previously accepted a list of events, it now accepts an attrset
                keyed by the event name.
              ''
              (
                lib.listToAttrs (
                  map
                    (e: {
                      name = e.event;
                      value = e.command;
                    })
                    events
                )
              )
          )
          (submodule eventsModule);
      default = { };
      example = literalExpression ''
        {
          "before-sleep" = "''${pkgs.swaylock}/bin/swaylock -fF";
          "lock" = "lock";
        }
      '';
      description = "Run command on occurrence of a event.";
    };
  };

  config = mkIf cfg.enable {
    hm.services.swayidle = {
      enable = true;
      package = cfg.package;
      timeouts = cfg.timeouts;
      events = cfg.events;
    };
  };
}
