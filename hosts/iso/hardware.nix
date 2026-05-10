{ nixpkgs, ... }: {
  imports = [ "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];
  nixpkgs.hostPlatform = "x86_64-linux";
}
