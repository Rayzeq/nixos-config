{ lib, config, ... }: {
  sunsetr = {
    enable = lib.mkDefault true;

    night.gamma = 70;
    latitude = config.globals.latitude;
    longitude = config.globals.longitude;
  };
}
