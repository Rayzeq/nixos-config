{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkEnableOption mkOption mkPackageOption mkIf literalExpression;
  cfg = config.zsh;

  atuinOptions = types.submodule {
    options = {
      enable = mkEnableOption "atuin";
      package = mkPackageOption pkgs "atuin" { };
      settings = mkOption {
        type = with types;
          let
            prim = oneOf [ bool int str ];
            primOrPrimAttrs = either prim (attrsOf prim);
            entry = either prim (listOf primOrPrimAttrs);
            entryOrAttrsOf = t: either entry (attrsOf t);
            entries = entryOrAttrsOf (entryOrAttrsOf entry);
          in
          attrsOf entries // { description = "Atuin configuration"; };
        default = { };
        example = literalExpression ''
          {
            auto_sync = true;
            sync_frequency = "5m";
            sync_address = "https://api.atuin.sh";
            search_mode = "prefix";
          }
        '';
        description = ''
          Configuration written to
          {file}`$XDG_CONFIG_HOME/atuin/config.toml`.

          See <https://atuin.sh/docs/config/> for the full list
          of options.
        '';
      };
    };
  };
  direnvOptions = types.submodule {
    options = {
      enable = mkEnableOption "direnv";
      package = mkPackageOption pkgs "direnv" { };
      nix-direnv = {
        enable = mkEnableOption "nix-direnv";
        package = mkPackageOption pkgs "nix-direnv" { };
      };

      hide_env_diff = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Set to true to hide the diff of the environment variables when loading the .envrc
        '';
      };
      log_format = mkOption {
        type = types.str;
        default = "direnv: %s";
        description = '''';
      };
    };
  };
in
{
  options.zsh = {
    enable = mkEnableOption "Zsh";

    # Plugins
    autojump.enable = mkEnableOption "autojump";
    atuin = mkOption {
      type = atuinOptions;
      default = { };
      description = "Options of atuin";
    };
    direnv = mkOption {
      type = direnvOptions;
      default = { };
      description = "Options of direnv";
    };
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

      initContent = ''export DIRENV_LOG_FORMAT="${cfg.direnv.log_format}"'';
    };

    autojump = mkIf cfg.autojump.enable {
      enable = true;
      enableZshIntegration = true;
    };
    atuin = mkIf cfg.atuin.enable {
      enable = true;
      package = cfg.atuin.package;
      enableZshIntegration = true;
      settings = cfg.atuin.settings;
    };
    direnv = mkIf cfg.direnv.enable {
      enable = true;
      package = cfg.direnv.package;
      enableZshIntegration = true;
      config.global.hide_env_diff = cfg.direnv.hide_env_diff;

      nix-direnv = mkIf cfg.direnv.nix-direnv.enable {
        enable = true;
        package = cfg.direnv.nix-direnv.package;
      };
    };
  };
}
