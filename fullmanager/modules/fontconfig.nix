{ lib, globals, ... }:
{
  config = {
    hm.home.packages = (
      map
        (f: f.package)
        (globals.font.sans.fallbacks ++ globals.font.monospace.fallbacks)
    ) ++ lib.optional (globals.font.sans.package != null) globals.font.sans.package
    ++ lib.optional (globals.font.monospace.package != null) globals.font.monospace.package;
    hm.fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ globals.font.sans.name ] ++ map (f: f.name) globals.font.sans.fallbacks;
        monospace = [ globals.font.monospace.name ] ++ map (f: f.name) globals.font.monospace.fallbacks;
      };
    };
  };
}
