{ nixpkgs, lib, ... }: {
  imports = lib.import [ ../../config/system ];

  system.system.stateVersion = nixpkgs.lib.trivial.release;
}
