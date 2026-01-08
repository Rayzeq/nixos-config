{ lib, systemConfig, modulesPath, ... }:
let
  hardware = import ./hardware.nix { inherit lib modulesPath; config = systemConfig; };
in
{
  system = hardware;
}
