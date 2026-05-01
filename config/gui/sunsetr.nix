{ lib, config, ... }: {
  sunsetr = {
    enable = true;

    night.gamma = 80;
    latitude = config.globals.latitude;
    longitude = config.globals.longitude;
  };
}
