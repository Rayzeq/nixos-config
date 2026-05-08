{ lib, ... }: {
  imports = lib.import { exclude = [ ../../../config/system ]; } [ ../../../config ];

  hm.home.stateVersion = "23.05";
}
