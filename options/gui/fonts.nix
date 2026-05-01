{ lib, config, ... }:
let
  inherit (lib) mkOption types literalExpression;
  cfg = config.fonts;

  fontType = types.submodule {
    options = {
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
        type = types.str;
        default = null;
        example = "Fira Code";
        description = ''
          The font family name within the package.
        '';
      };

      type = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "monospace";
        description = ''
          The type of the font (main ones being `serif`, `sans-serif`, `monospace` and `cursive`).
        '';
      };

      features = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "subpixel_antialias" "ss03" "ss05" ];
        description = ''
          The font features to enable.
        '';
      };
    };
  };
in
{
  options.fonts = {
    serif = mkOption {
      type = types.listOf fontType;
      default = [ ];
      description = "Default serif fonts.";
    };
    sans-serif = mkOption {
      type = types.listOf fontType;
      default = [ ];
      description = "Default sans-serif fonts.";
    };
    monospace = mkOption {
      type = types.listOf fontType;
      default = [ ];
      description = "Default monospace fonts.";
    };

    fonts = mkOption {
      type = types.attrsOf fontType;
      default = { };
      description = "List of fonts to install.";
    };
  };

  config = {
    lib.types.font = fontType;
    system.fonts = {
      packages = lib.mapAttrsToList (_: font: font.package) cfg.fonts;
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = map (font: font.name) cfg.serif;
          sansSerif = map (font: font.name) cfg.sans-serif;
          monospace = map (font: font.name) cfg.monospace;
        };
        localConf =
          let
            blocks = lib.mapAttrsToList
              (_: font: ''
                <alias>
                  <family>${font.name}</family>
                  <default>
                    <family>${font.type}</family>
                  </default>
                </alias>'')
              cfg.fonts;
          in
          ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
            <fontconfig>
              ${builtins.concatStringsSep "\n" blocks}

              <!-- by default fontconfig assumes any unrecognized font is sans-serif, so -->
              <!-- the fonts above now have /both/ families.  fix this. -->
              <!-- note that "delete" applies to the first match -->
              <match>
                <test compare="eq" name="family">
                  <string>sans-serif</string>
                </test>
                <test compare="eq" name="family">
                  <string>monospace</string>
                </test>
                <edit mode="delete" name="family"/>
              </match>
              <match>
                <test compare="eq" name="family">
                  <string>sans-serif</string>
                </test>
                <test compare="eq" name="family">
                  <string>serif</string>
                </test>
                <edit mode="delete" name="family"/>
              </match>
            </fontconfig>
          '';
      };
    };
  };
}
