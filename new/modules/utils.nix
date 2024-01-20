{ lib, ... }:
with lib; {
  attrItems = attrset: builtins.attrValues (
    builtins.mapAttrs
      (name: value: { inherit name value; })
      attrset
  );
  types.font = {
    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      example = literalExpression "pkgs.fira-code";
      description = ''
        Package providing the font. This package will be installed
        to your profile. If `null` then the font
        is assumed to already be available in your profile.
      '';
    };

    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "Fira Code";
      description = ''
        The family name of the font within the package.
      '';
    };

    size = mkOption {
      type = types.nullOr types.number;
      default = null;
      example = "8";
      description = ''
        The size of the font.
      '';
    };

    features = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = ''[ "subpixel_antialias" "ss03" "ss05" ]'';
      description = ''
        The font features to enable.
      '';
    };
  };
}
