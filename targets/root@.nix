{ lib, ... }: {
  imports = lib.import { exclude = [ ../config/shell/nh.nix ]; } [
    ../config/shell
    ../config/gui/fonts.nix
    ../config/gui/sublime-text
    ../config/gui/sublime-merge.nix
  ];
}
