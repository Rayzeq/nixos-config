{ config, lib, pkgs, hmConfig, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf types literalExpression;
  cfg = config.sunsetr;

  tomlFormat = pkgs.formats.toml { };
in
{
  options.sunsetr = {
    enable = mkEnableOption "sunsetr";
    package = mkPackageOption pkgs "sunsetr" { };

    backend = mkOption {
      type = types.enum [ "auto" "hyprland" "hyprsunset" "wayland" ];
      default = "auto";
      example = "hyprland";
    };

    transition-mode = mkOption {
      type = types.enum [ "geo" "finish_by" "start_at" "center" "static" ];
      default = "geo";
      example = "static";
    };

    smoothing = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Enable smooth transitions during startup and exit.
      '';
    };

    startup-duration = mkOption {
      type = types.numbers.between 0 60;
      default = 0.5;
      example = 0;
      description = ''
        Duration of smooth startup in seconds.
      '';
    };

    shutdown-duration = mkOption {
      type = types.numbers.between 0 60;
      default = 0.5;
      example = 0;
      description = ''
        Duration of smooth shutdown in seconds.
      '';
    };

    adaptive-interval = mkOption {
      type = types.numbers.between 1 1000;
      default = 1;
      example = 500;
      description = ''
        Adaptive interval base for smooth transitions in milliseconds.
      '';
    };

    night = {
      temperature = mkOption {
        type = types.numbers.between 1000 20000;
        default = 3300;
        example = 3500;
        description = ''
          Color temperature during night in Kelvin.
        '';
      };

      gamma = mkOption {
        type = types.numbers.between 10 200;
        default = 90;
        example = 70;
        description = ''
          Gamma percentage for day.
        '';
      };
    };

    day = {
      temperature = mkOption {
        type = types.numbers.between 1000 20000;
        default = 6500;
        example = 6700;
        description = ''
          Color temperature during day in Kelvin.
        '';
      };

      gamma = mkOption {
        type = types.numbers.between 10 200;
        default = 100;
        example = 90;
        description = ''
          Gamma percentage for day.
        '';
      };
    };

    update-interval = mkOption {
      type = types.numbers.between 10 300;
      default = 60;
      example = 30;
      description = ''
        Update frequency during transitions in seconds.
      '';
    };

    latitude = mkOption {
      type = with types; nullOr float;
      default = null;
      example = -74.3;
      description = ''
        Your current latitude, between `-90.0` and `90.0`.
      '';
    };

    longitude = mkOption {
      type = with types; nullOr float;
      default = null;
      example = 12.5;
      description = ''
        Your current longitude, between `-180.0` and `180.0`.
      '';
    };

    systemdTarget = mkOption {
      type = with types; str;
      default = hmConfig.wayland.systemd.target;
      defaultText = literalExpression "config.wayland.systemd.target";
      description = ''
        Systemd target to bind to.
      '';
    };
  };

  config.hm = mkIf cfg.enable {
    xdg.configFile."sunsetr/sunsetr.toml".source = tomlFormat.generate "sunsetr.toml" {
      inherit (cfg) backend smoothing latitude longitude;
      transition_mode = cfg.transition-mode;
      startup_duration = cfg.startup-duration;
      shutdown_duration = cfg.shutdown-duration;
      adaptive_interval = cfg.adaptive-interval;
      update_interval = cfg.update-interval;

      night_temp = cfg.night.temperature;
      night_gamma = cfg.night.gamma;
      day_temp = cfg.day.temperature;
      day_gamma = cfg.day.gamma;
    };
    systemd.user.services.sunsetr = {
      Unit = {
        Description = "Day/night gamma and temperature adjustments for Wayland compositors.";
        After = [ cfg.systemdTarget ];
        PartOf = [ cfg.systemdTarget ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/sunsetr";
      };

      Install = {
        WantedBy = [ cfg.systemdTarget ];
      };
    };
  };
}
