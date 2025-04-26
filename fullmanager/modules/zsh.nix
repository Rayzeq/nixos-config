{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkEnableOption mkOption mkPackageOption mkIf literalExpression
    optionalString concatStringsSep mapAttrsToList;
  cfg = config.zsh;

  historyOptions = types.submodule {
    options = {
      size = mkOption {
        type = types.int;
        default = 10000;
        description = "Number of history lines to keep.";
      };

      save = mkOption {
        type = types.int;
        defaultText = 10000;
        default = cfg.history.size;
        description = "Number of history lines to save.";
      };

      path = mkOption {
        type = types.str;
        default = "$HOME/.zsh_history";
        example = literalExpression ''"''${config.xdg.dataHome}/zsh/zsh_history"'';
        description = "History file location";
      };

      ignorePatterns = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = literalExpression ''[ "rm *" "pkill *" ]'';
        description = ''
          Do not enter command lines into the history list
          if they match any one of the given shell patterns.
        '';
      };

      ignoreDups = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Do not enter command lines into the history list
          if they are duplicates of the previous event.
        '';
      };

      ignoreAllDups = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If a new command line being added to the history list
          duplicates an older one, the older command is removed
          from the list (even if it is not the previous event).
        '';
      };

      ignoreSpace = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Do not enter command lines into the history list
          if the first character is a space.
        '';
      };

      expireDuplicatesFirst = mkOption {
        type = types.bool;
        default = false;
        description = "Expire duplicates first.";
      };

      extended = mkOption {
        type = types.bool;
        default = false;
        description = "Save timestamp into the history file.";
      };

      share = mkOption {
        type = types.bool;
        default = true;
        description = "Share command history between zsh sessions.";
      };
    };
  };
  autosuggestionsOptions = types.submodule {
    options = {
      enable = mkEnableOption "zsh autosuggestions";
      strategy = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "history" "completion" ];
        description = "Options related to commands history configuration.";
      };
    };
  };
  autocompleteOptions = types.submodule {
    options = {
      enable = mkEnableOption "zsh-autocomplete";
      package = mkPackageOption pkgs "zsh-autocomplete" { };
    };
  };
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
  syntaxHighlightingOptions = types.submodule {
    options = {
      enable = mkEnableOption "zsh syntax highlighting";
      package = mkPackageOption pkgs "zsh-syntax-highlighting" { };

      highlighters = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "brackets" ];
        description = ''
          Highlighters to enable
          See the list of highlighters: <https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md>
        '';
      };

      styles = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = { comment = "fg=black,bold"; };
        description = ''
          Custom styles for syntax highlighting.
          See each highlighter's options: <https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md>
        '';
      };
    };
  };
  p10kOptions = types.submodule {
    options = {
      enable = mkEnableOption "powerlevel10k";
      package = mkPackageOption pkgs "zsh-powerlevel10k" { };

      instant-prompt = mkOption {
        type = types.bool;
        default = false;
        example = true;
        description = ''
          Whether to enable instant prompt
        '';
      };

      config = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = literalExpression "./p10k-config";
        description = ''
          The path to a directory containing a file named `p10k.zsh`
        '';
      };
    };
  };
  ohMyZshOptions = types.submodule {
    options = {
      enable = mkEnableOption "oh-my-zsh";
      package = mkPackageOption pkgs "oh-my-zsh" { };

      plugins = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "git" "sudo" ];
        description = ''
          List of oh-my-zsh plugins
        '';
      };

      p10k = mkOption {
        type = p10kOptions;
        default = { };
        description = "Options to configure powerlevel10k.";
      };
    };
  };
in
{
  options.zsh = {
    enable = mkEnableOption "Zsh";
    package = mkPackageOption pkgs "zsh" { };

    autocd = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Automatically enter into a directory if typed directly into shell.
      '';
    };

    history = mkOption {
      type = historyOptions;
      default = { };
      description = "Options related to commands history configuration.";
    };

    # Plugins
    autojump.enable = mkEnableOption "autojump";
    autosuggestions = mkOption {
      type = autosuggestionsOptions;
      default = { };
      description = "Options of zsh-autosuggestions";
    };
    autocomplete = mkOption {
      type = autocompleteOptions;
      default = { };
      description = "Options of zsh-autocomplete";
    };
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

    syntaxHighlighting = mkOption {
      type = syntaxHighlightingOptions;
      default = { };
      description = "Options related to zsh-syntax-highlighting.";
    };

    oh-my-zsh = mkOption {
      type = ohMyZshOptions;
      default = { };
      description = "Options to configure oh-my-zsh.";
    };

    keybinds = mkOption {
      type = types.attrsOf (types.either types.str (types.attrsOf types.str));
      default = { };
      example = {
        "^H" = "backward-kill-word";
      };
      description = "Keybinds to create.";
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

  config = mkIf cfg.enable {
    hm.programs.zsh = {
      enable = true;
      package = cfg.package;

      autocd = cfg.autocd;
      history = cfg.history;
      autosuggestion.enable = cfg.autosuggestions.enable;
      syntaxHighlighting = cfg.syntaxHighlighting;

      oh-my-zsh = mkIf cfg.oh-my-zsh.enable {
        enable = true;
        package = cfg.oh-my-zsh.package;
        plugins = cfg.oh-my-zsh.plugins;
      };

      plugins = [
        (mkIf cfg.oh-my-zsh.p10k.enable {
          name = "powerlevel10k";
          src = cfg.oh-my-zsh.p10k.package;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        })
        (mkIf (cfg.oh-my-zsh.p10k.enable && cfg.oh-my-zsh.p10k.config != null) {
          name = "powerlevel10k-config";
          src = lib.cleanSource cfg.oh-my-zsh.p10k.config;
          file = "p10k.zsh";
        })
        (mkIf cfg.autocomplete.enable {
          name = "zsh-autocomplete";
          src = cfg.autocomplete.package;
          file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
        })
      ];

      shellAliases = cfg.aliases;

      initContent = lib.mkMerge [
        (lib.mkBefore (optionalString (cfg.oh-my-zsh.p10k.enable && cfg.oh-my-zsh.p10k.instant-prompt) ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        ''))
        (concatStringsSep "\n" ([
          ''export DIRENV_LOG_FORMAT="${cfg.direnv.log_format}"''
          (optionalString cfg.autosuggestions.enable ''
            ZSH_AUTOSUGGEST_STRATEGY=(${concatStringsSep " " cfg.autosuggestions.strategy})
          '')
        ] ++ mapAttrsToList
          (key: action:
            if builtins.typeOf action == "string" then
              "bindkey '${key}' ${action}"
            else
              let keymap = key; keybinds = action; in
              concatStringsSep "\n" (mapAttrsToList (key: action: "bindkey -M ${keymap} '${key}' ${action}") keybinds)
          )
          cfg.keybinds
        ))
      ];
    };

    hm.programs.autojump = mkIf cfg.autojump.enable {
      enable = true;
      enableZshIntegration = true;
    };
    hm.programs.atuin = mkIf cfg.atuin.enable {
      enable = true;
      package = cfg.atuin.package;
      enableZshIntegration = true;
      settings = cfg.atuin.settings;
    };
    hm.programs.direnv = mkIf cfg.direnv.enable {
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
