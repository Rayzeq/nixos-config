{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options = {
    lib = mkOption {
      type = with types; attrsOf anything;
      default = { };
      description = ''
        This option allows modules to define helper functions, constants, etc.
      '';
    };
  };
}
