{ globals, ... }:
let
  config = import ../configuration/wlsunset.nix {
    inherit globals;
  };
in
if config.enable then {
  services.wlsunset = {
    enable = true;
    latitude = builtins.toString config.latitude;
    longitude = builtins.toString config.longitude;
  };
} else {
  services.wlsunset.enable = false;
}
