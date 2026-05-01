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

    globals = mkOption {
      type = with types; attrsOf anything;
      default = { };
      description = ''
        This option allows modules to define global values.
      '';
    };
  };

  config = {
    lib = rec {
      rgba = r: g: b: a: {
        r = r;
        g = g;
        b = b;
        a = a;
        css = "rgba(${toString r}, ${toString g}, ${toString b}, ${toString a})";
      };
      rgb = r: g: b: rgba r g b 1;
    };
  };
}
