{ globals, ... }:
let
  config = import ../configuration/wlogout {
    inherit globals;
  };
in
if config.enable then {
  programs.wlogout = config;
} else {
  programs.wlogout.enable = false;
}
