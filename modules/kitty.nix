{ home-manager, lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.kitty;

  kittyOptions = lib.getOptions "${home-manager}/modules/programs/kitty.nix";

  postscriptNames = pkgs.runCommand "get-postscript-names"
    {
      nativeBuildInputs = [ pkgs.fontconfig ];
      FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ cfg.font.package ]; };
    }
    ''
      ${pkgs.fontconfig}/bin/fc-list "${cfg.font.name}" -f "%{postscriptname}\n" | ${pkgs.coreutils}/bin/sort -u | ${pkgs.gnugrep}/bin/grep -v "^$" | ${pkgs.coreutils}/bin/head -c -1 > $out
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
