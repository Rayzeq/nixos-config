{ lib, config, ... }:
let
  inherit (lib) types mkOption attrValues concatStringsSep;
  cfg = config.font;

  fontType = (import ./types.nix { inherit lib; }).font;
in
{
  options.font = {
    serif = mkOption {
      type = types.listOf fontType;
      default = [ ];
      description = "Defaults font for this family";
    };
    sans-serif = mkOption {
      type = types.listOf fontType;
      default = [ ];
      description = "Defaults font for this family";
    };
    monospace = mkOption {
      type = types.listOf fontType;
      default = [ ];
      description = "Defaults font for this family";
    };

    fonts = mkOption {
      type = types.attrsOf fontType;
      default = { };
      description = "List of fonts to install.";
    };
  };

  config = {
    system.fonts = {
      packages = map (font: font.package) (attrValues cfg.fonts);
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = map (font: font.name) cfg.serif;
          sansSerif = map (font: font.name) cfg.sans-serif;
          monospace = map (font: font.name) cfg.monospace;
        };
        localConf =
          let
            blocks = map
              (font: ''
                <alias>
                  <family>${font.name}</family>
                  <default>
                    <family>${font.type}</family>
                  </default>
                </alias>'')
              (attrValues cfg.fonts);
          in
          ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
            <fontconfig>
              ${concatStringsSep "\n" blocks}

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
