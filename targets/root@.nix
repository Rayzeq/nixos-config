{ lib, ... }: {
  imports = lib.import { exclude = [ ../config/shell/nh.nix ]; } [
    ../config/shell
    ../config/desktop/fonts.nix
    ../config/programs/sublime-text
    ../config/programs/sublime-merge.nix
  ];
}
