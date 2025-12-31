{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkOption mkIf;
  inherit (builtins) concatStringsSep;
  cfg = config.kitty;
  fontType = (import ./types.nix { inherit lib; }).font;

  kittyOptions = (import <home-manager/modules/programs/kitty.nix> {
    inherit lib pkgs;
    config = { };
  }).options.programs.kitty;

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
      type = types.nullOr fontType;
      default = null;
    };
  };

  config.hm.programs.kitty = mkIf cfg.enable {
    inherit (cfg) enable package settings keybindings;
    font = {
      inherit (cfg.font) package name;
    };
    extraConfig = concatStringsSep "\n" (map
      (name:
        "font_features ${name} ${concatStringsSep " " (map (feature: "+${feature}") cfg.font.features)}"
      )
      namesList);
  };
}
