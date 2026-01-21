{ pkgs, lib, config, hmConfig, ... }:
let
  inherit (lib) mkEnableOption mkPackageOption;
  cfg = config.wayland-pipewire-idle-inhibit;
in
{
  options.wayland-pipewire-idle-inhibit = {
    enable = mkEnableOption "wayland-pipewire-idle-inhibit";
    package = mkPackageOption pkgs "wayland-pipewire-idle-inhibit" { };
  };

  config.hm = lib.mkIf cfg.enable {
    systemd.user.services.wayland-pipewire-idle-inhibit = {
      Unit = {
        Description = "Inhibit Wayland idling when media is played through pipewire";
        Documentation = "https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit";
        PartOf = [ hmConfig.wayland.systemd.target ];
        After = [ hmConfig.wayland.systemd.target ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/wayland-pipewire-idle-inhibit";
        Restart = "always";
        RestartSec = 10;
      };

      Install.WantedBy = [ hmConfig.wayland.systemd.target ];
    };
  };
}
