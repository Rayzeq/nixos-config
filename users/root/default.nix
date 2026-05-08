{ lib, ... }: {
  imports = lib.import { exclude = [ ../../config/shell/nh.nix ]; } [
    ../../config/shell
    ../../config/desktop/fonts.nix
    ../../config/programs/development/sublime-text
    ../../config/programs/development/sublime-merge.nix
  ];
}
