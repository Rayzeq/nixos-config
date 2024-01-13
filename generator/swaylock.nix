{ unstable, globals, ... }:
let
  config = import ../configuration/swaylock.nix {
    inherit globals;
  };
in
if config.enable then {
  programs.swaylock = {
    enable = true;
    package = unstable.swaylock-effects;
    settings = builtins.removeAttrs config [ "enable" ];
  };
  system.security.pam.services.swaylock = { };
} else {
  programs.swaylock.enable = false;
}
