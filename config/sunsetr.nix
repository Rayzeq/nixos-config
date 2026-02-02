{ lib, config, ... }: {
  sunsetr = {
    enable = lib.mkDefault true;

    night.gamma = 80;
    latitude = config.globals.latitude;
    longitude = config.globals.longitude;
  };
}
