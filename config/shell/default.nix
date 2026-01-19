{ lib, config, ... }: {
  zsh = {
    enable = lib.mkDefault true;

    # note: this is the default when stateVersion >= 26.05
    dotDir = "${config.xdg.configHome}/zsh";

    autocd = true;
    history = {
      share = false;
      append = true;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    autosuggestion = {
      enable = true;
      strategy = [ "history" "completion" ];
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "colored-man-pages" "rust" "sublime" ];
    };
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "brackets" ];
    };

    autocomplete.enable = true;
    p10k = {
      enable = true;
      instant-prompt = true;
      config = ./p10k.zsh;
    };

    keybinds = {
      "^H" = "backward-kill-word";
      "5~" = "kill-word";
      "^K" = "backward-kill-line";

      # somehow zsh-autocomplete broke those ones
      "^[[H" = "beginning-of-line";
      "^[[F" = "end-of-line";
      # use tab to trigger and navigate completions
      "\\t" = ''menu-select "$terminfo[kcbt]" menu-select'';
      menuselect = {
        "\\t" = ''menu-complete "$terminfo[kcbt]" reverse-menu-complete'';
      };
    };
  };
}
