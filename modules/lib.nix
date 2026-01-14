{ lib, ... }:
let
  inherit (lib) types mkOption literalExpression;
in
{
  font = types.submodule {
    options = {
      package = mkOption {
        type = with types; nullOr package;
        default = null;
        example = literalExpression "pkgs.fira-code";
        description = ''
          Package providing the font. This package will be installed
          to your profile. If `null` then the font
          is assumed to already be available in your profile.
        '';
      };

      name = mkOption {
        type = types.str;
        default = null;
        example = "Fira Code";
        description = ''
          The family name of the font within the package.
        '';
      };

      type = mkOption {
        type = with types; nullOr str;
        default = null;
        example = "monospace";
        description = ''
          The type of the font (main ones being `serif`, `sans-serif`, `monospace` and `cursive`).
        '';
      };

      features = mkOption {
        type = with types; listOf str;
        default = [ ];
        example = ''[ "subpixel_antialias" "ss03" "ss05" ]'';
        description = ''
          The font features to enable.
        '';
      };
    };
  };
}
