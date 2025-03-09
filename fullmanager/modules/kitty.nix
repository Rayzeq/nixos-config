{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkEnableOption mkOption mkPackageOption mkIf literalExpression concatStringsSep;
  cfg = config.kitty;
  fontType = (import ./types.nix { inherit lib; }).font;

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
    enable = mkEnableOption "Kitty";
    package = mkPackageOption pkgs "kitty" { };

    font = mkOption {
      type = types.nullOr fontType;
      default = null;
    };

    keybindings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Mapping of keybindings to actions.";
      example = literalExpression ''
        {
          "ctrl+c" = "copy_or_interrupt";
          "ctrl+f>2" = "set_font_size 20";
        }
      '';
    };

    settings = mkOption {
      type = types.attrsOf (types.either types.str (types.either types.bool types.int));
      default = { };
      example = literalExpression ''
        {
          scrollback_lines = 10000;
          enable_audio_bell = false;
          update_check_interval = 0;
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/kitty/kitty.conf`. See
        <https://sw.kovidgoyal.net/kitty/conf.html>
        for the documentation.
      '';
    };
  };

  config = mkIf cfg.enable {
    hm.programs.kitty = {
      enable = true;
      package = cfg.package;
      # Unfortunatly font features doesn't seem to work with Fira Code
      font = {
        package = cfg.font.package;
        name = cfg.font.name;
      };
      settings = cfg.settings;
      keybindings = cfg.keybindings;
      extraConfig = concatStringsSep "\n" (map
        (name:
          "font_features ${name} ${concatStringsSep " " (map (feature: "+${feature}") cfg.font.features)}"
        )
        namesList);
    };
  };
}
