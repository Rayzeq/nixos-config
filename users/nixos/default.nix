{ lib, ... }: {
  imports = lib.import [
    ../../config/globals.nix
    ../../config/shell
    ../../config/desktop
    ../../config/programs/development/sublime-text
    ../../config/programs/development/sublime-merge.nix
  ];
}
