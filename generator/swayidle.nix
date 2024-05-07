{ pkgs, unstable, ... }:
let
  config = import ../configuration/swayidle.nix {
    inherit pkgs unstable;
  };
in
if config.enable then {
  services.swayidle = {
    enable = true;
    timeouts = config.timeouts;
    events = config.events;
  };
} else {
  programs.swayidle.enable = false;
}
