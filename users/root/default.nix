{ lib, ... }: {
  imports = lib.import { exclude = [ ../../config/shell/nh.nix ]; } [
    ../../config/shell
    ../../config/desktop/fonts.nix
    ../../config/programs/development/sublime-text
    ../../config/programs/development/sublime-merge.nix
    # needed to provide shell definitions for xterm-kitty
    ../../config/desktop/kitty.nix
  ];

  hm.programs.firefox.enable = false;
}
