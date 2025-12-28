{ globals, ... }: {
  wlsunset = {
    enable = true;
    latitude = globals.latitude;
    longitude = globals.longitude;
  };
}
