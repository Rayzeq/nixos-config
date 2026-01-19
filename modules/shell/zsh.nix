{ home-manager, pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkMerge mkIf mkBefore types literalExpression;
  cfg = config.zsh;

  zshOptions =
    (lib.getOptions "${home-manager}/modules/programs/zsh/default.nix") //
    (lib.getOptions "${home-manager}/modules/programs/zsh/history.nix") //
    (lib.getOptions "${home-manager}/modules/programs/zsh/plugins/oh-my-zsh.nix");
in
{
  options.zsh = {
    inherit (zshOptions) enable package autocd autosuggestion dotDir history oh-my-zsh syntaxHighlighting;

    autocomplete = {
      enable = mkEnableOption "zsh-autocomplete";
      package = mkPackageOption pkgs "zsh-autocomplete" { };
    };

    p10k = {
      enable = mkEnableOption "powerlevel10k";
      package = mkPackageOption pkgs "zsh-powerlevel10k" { };

      instant-prompt = mkOption {
        type = types.bool;
        default = false;
        example = true;
        description = ''
          Whether to enable the instant prompt.
        '';
      };

      config = mkOption {
        type = with types; nullOr path;
        default = null;
        example = literalExpression "./p10k.zsh";
        description = ''
          The path to the p10k config file.
        '';
      };
    };

    keybinds = mkOption {
      type = with types; attrsOf (either str (attrsOf str));
      default = { };
      example = {
        "^H" = "backward-kill-word";
      };
      description = "Keybinds to setup.";
    };
  };

  config.hm.programs.zsh = mkIf cfg.enable {
    inherit (cfg) enable package autocd autosuggestion dotDir history oh-my-zsh syntaxHighlighting;

    plugins = [
      (mkIf cfg.p10k.enable {
        name = "powerlevel10k";
        src = cfg.p10k.package;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      })
      (mkIf (cfg.p10k.enable && cfg.p10k.config != null) {
        name = "powerlevel10k-config";
        src = pkgs.runCommand "p10k-config" { } ''
          mkdir $out
          cp "${cfg.p10k.config}" $out/p10k.zsh
        '';
        file = "p10k.zsh";
      })
      (mkIf cfg.autocomplete.enable {
        name = "zsh-autocomplete";
        src = cfg.autocomplete.package;
        file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
      })
    ];

    initContent = mkMerge [
      (mkBefore (lib.optionalString (cfg.p10k.enable && cfg.p10k.instant-prompt) ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      ''))
      (lib.concatMapAttrsStringSep "\n"
        (key: action:
          if builtins.typeOf action == "string" then
            "bindkey '${key}' ${action}"
          else
            let
              keymap = key;
              keybinds = action;
            in
            lib.concatMapAttrsStringSep "\n" (key: action: "bindkey -M ${keymap} '${key}' ${action}") keybinds
        )
        cfg.keybinds
      )
    ];
  };
}
