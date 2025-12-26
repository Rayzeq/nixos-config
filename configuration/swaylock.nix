{ globals, ... }: {
  enable = true;

  image = globals.dataFile."wallpapers/light2.png".target;
  effect-blur = "7x5";
  effect-vignette = "0.5:0.5";

  indicator = true;
  indicator-x-position = 979;
  indicator-y-position = 566;
  indicator-radius = 294;
  indicator-thickness = 91;
  clock = true;
  datestr = "";

  text-color = "000000";
  text-caps-lock-color = "000000";
  font = globals.font.family;
  font-size = 70;

  inside-color = "00000000";
  inside-clear-color = "00000000";
  inside-ver-color = "00000000";
  inside-wrong-color = "00000000";

  line-uses-inside = true;

  ring-color = "00000000";
  ring-clear-color = "ffa50033";
  ring-ver-color = "0000ff33";
  ring-wrong-color = "ff000033";
  separator-color = "00000000";
  key-hl-color = "00ff0033";
  bs-hl-color = "ff000033";
}
