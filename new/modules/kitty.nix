{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.bettermanager.kitty;
  utils = import ./utils.nix { inherit lib; };
in
{
  options.bettermanager.kitty = {
    enable = mkEnableOption "Kitty";
    package = mkPackageOption pkgs "kitty" { };

    font = utils.types.font;

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
    home.packages = cfg.font.fallbacks;
    programs.kitty = {
      enable = true;
      package = cfg.package;
      # Unfortunatly font features doesn't seem to work with Fira Code
      font = removeAttrs cfg.font [ "fallbacks" "features" ];
      keybindings = cfg.keybindings;
      settings = cfg.settings;
    };
  };
}
