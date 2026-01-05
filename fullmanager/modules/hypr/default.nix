{ lib, ... }: {
  imports = lib.getModules ./. [ "default.nix" ];
}
