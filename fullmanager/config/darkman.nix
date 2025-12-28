{ globals, ... }: {
  darkman = {
    enable = true;

    settings = {
      lat = globals.latitude;
      lng = globals.longitude;
      usegeoclue = false;
    };
  };
}
