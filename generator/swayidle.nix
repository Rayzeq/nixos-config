{ pkgs, globals, ... }:
let
  config = import ../configuration/swayidle.nix {
    inherit pkgs;
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
