{ config, ... }: {
  globals = {
    latitude = 46.6;
    longitude = 1.6;

    theme.overlay = {
      background = config.lib.rgba 0 0 0 0.7;
    };
  };
}
