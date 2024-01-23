{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.bettermanager.zsh;
  utils = import ./utils.nix { inherit lib; };

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
  options.bettermanager.zsh = {
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

    autosuggestions = mkOption {
      type = autosuggestionsOptions;
      default = { };
      description = "Options of zsh-autosuggestions";
    };

    autojump.enable = mkEnableOption "autojump";
    autocomplete = mkOption {
      type = autocompleteOptions;
      default = { };
      description = "Options of zsh-autocomplete";
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
      type = types.attrsOf types.str;
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
    programs.zsh = {
      enable = true;
      package = cfg.package;

      autocd = cfg.autocd;
      history = cfg.history;
      enableAutosuggestions = cfg.autosuggestions.enable;
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

      initExtraFirst = optionalString (cfg.oh-my-zsh.p10k.enable && cfg.oh-my-zsh.p10k.instant-prompt) ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      initExtra = concatStringsSep "\n" ([
        (optionalString cfg.autosuggestions.enable ''
          ZSH_AUTOSUGGEST_STRATEGY=(${concatStringsSep " " cfg.autosuggestions.strategy})
        '')
      ] ++ mapAttrsToList (key: action: "bindkey '${key}' ${action}") cfg.keybinds);
    };

    programs.autojump = mkIf cfg.autojump.enable {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
