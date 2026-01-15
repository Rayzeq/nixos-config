{ home-manager, lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.kitty;

  kittyOptions = lib.getOptions "${home-manager}/modules/programs/kitty.nix";

  postscriptNames = pkgs.runCommand "get-postscript-names" { }
    ''
      # Can't use fc-scan because no config is available, and we can't write cache
      # file=${pkgs.fontconfig}/bin/fc-match -f="%{file}" "${cfg.font.name}" | cut -c2-
      file=$(find ${cfg.font.package} -name "*.ttf")
      ${pkgs.fontconfig}/bin/fc-scan -f="%{postscriptname}\n" "$file" 2>/dev/null | cut -c2- | grep -v "^$" | head -c -1 > $out
    '';
  namesList = lib.splitString "\n" (builtins.readFile postscriptNames);
in
{
  options.kitty = {
    inherit (kittyOptions) enable package settings keybindings;

    font = mkOption {
      type = types.nullOr config.lib.types.font;
      default = null;
      description = ''
        The font to use.
      '';
    };
  };

  config.hm.programs.kitty = mkIf cfg.enable {
    inherit (cfg) enable package settings keybindings;
    font = mkIf (cfg.font != null) {
      inherit (cfg.font) package name;
    };
    extraConfig = lib.concatMapStringsSep "\n"
      (name:
        "font_features ${name} ${lib.concatMapStringsSep " " (feature: "+${feature}") cfg.font.features}"
      )
      namesList;
  };
}
