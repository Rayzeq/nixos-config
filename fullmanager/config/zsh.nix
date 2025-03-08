{ ... }: {
  zsh = {
    enable = true;

    autocd = true;
    history.share = false;

    autosuggestions = {
      enable = true;
      strategy = [ "history" "completion" ];
    };
    atuin = {
      enable = true;
      settings = {
        update_check = false;
        filter_mode = "session";
        enter_accept = true;
      };
    };
    autojump.enable = true;
    autocomplete.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "brackets" ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;

      hide_env_diff = true;
      log_format = ''$(printf "\033[2mdirenv: %%s\033[0m")'';
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "command-not-found" "colored-man-pages" "git" "python" "rust" "sublime" ];
      p10k = {
        enable = true;
        instant-prompt = true;
        config = ./p10k-config;
      };
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

    aliases = {
      fix = "reset; stty sane; tput rs1; echo -e \"\\033c\"; clear";
      # safety net when using mv
      mv = "mv -b -i";
      ls = "lsd";
      cat = "bat";
      ssh = "kitten ssh";
      grep = "rg";
      sudogui = "sudo -EH";
      # force scrollback clear on kitty
      clear = "clear -T xterm-256color";
      dust = "sudo dust -rx";
      discord = "discord --enable-features=UseOzonePlatform --ozone-platform=wayland";
      system-update = "sudo zsh -c \"nix-channel --update home-manager && nixos-rebuild switch --upgrade\"";
      nixos-cleanup = "nix-collect-garbage -d; sudo zsh -c \"nix-collect-garbage -d && nixos-rebuild boot\"; echo \"\\nGC Roots:\\n\"; ls -l /nix/var/nix/gcroots/auto/";
    };
  };
}

