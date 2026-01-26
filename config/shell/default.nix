{ pkgs, lib, config, ... }: {
  packages = with pkgs; [
    file

    # development man pages (i.e C functions and such)
    man-pages
    man-pages-posix
  ];

  defaultShell = "zsh";
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

    autocomplete = {
      enable = true;
      package = pkgs.zsh-autocomplete.overrideAttrs (oldAttrs: rec {
        version = "23.07.13";

        src = pkgs.fetchFromGitHub {
          owner = "marlonrichert";
          repo = "zsh-autocomplete";
          rev = version;
          sha256 = "sha256-0NW0TI//qFpUA2Hdx6NaYdQIIUpRSd0Y4NhwBbdssCs=";
        };
      });
    };
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
  shellAliases = {
    fix = "reset; stty sane; tput rs1; echo -e \"\\x1bc\"; clear";
    # safety net when using mv
    mv = "mv -bi";
    # allow graphical applications to start under sudo
    sudogui = "sudo -EH";
    dust = "sudo dust -rx";
  };

  nix-index.enable = true;
  atuin = {
    enable = true;

    settings = {
      update_check = false;
      filter_mode = "session";
      enter_accept = true;
      inline_height = 0;
    };
  };
  direnv = {
    enable = true;
    nix-direnv.enable = true;

    config.global = {
      hide_env_diff = true;
      log_format = "\\u001b[2mdirenv: %s\\u001b[0m";
    };
  };

  lsd.enable = true;
  bat.enable = true;
  ripgrep.enable = true;
}
