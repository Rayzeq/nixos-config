{ lib, globals, ... }: {
  wlsunset = {
    enable = lib.mkDefault true;
    latitude = globals.latitude;
    longitude = globals.longitude;
  };
}
