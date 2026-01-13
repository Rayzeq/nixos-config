{ lib, globals, ... }: {
  sunsetr = {
    enable = lib.mkDefault true;

    night.gamma = 70;
    latitude = globals.latitude;
    longitude = globals.longitude;
  };
}
