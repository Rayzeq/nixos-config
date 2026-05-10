{ nixpkgs, ... }: {
  hm.home.stateVersion = nixpkgs.lib.trivial.release;
}
