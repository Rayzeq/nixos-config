{ lib, config, ... }:
let
  inherit (lib) types mkEnableOption mkOption mkIf literalExpression;
  cfg = config.zsh;
in
{
  options.zsh = {
    enable = mkEnableOption "Zsh";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = literalExpression ''
        {
          ll = "ls -l";
          ".." = "cd ..";
        }
      '';
      description = ''
        An attribute set that maps aliases (the top level attribute names in
        this option) to command strings or directly to build outputs.
      '';
    };
  };

  config.hm.programs = mkIf cfg.enable {
    zsh = {
      shellAliases = cfg.aliases;
    };
  };
}
