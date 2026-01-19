{ nixpkgs, lib, config, ... }:
let
  cfg = config.nix-index;

  nix-indexOptions = lib.getOptions "${nixpkgs}/nixos/modules/programs/nix-index.nix";
in
{
  options.nix-index = {
    inherit (nix-indexOptions) enable;
  };
  config.system.programs.nix-index = lib.mkIf cfg.enable cfg;
}
