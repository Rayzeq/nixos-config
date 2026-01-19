{ lib, ... }: {
  zsh = {
    enable = lib.mkDefault true;

    aliases = {
      fix = "reset; stty sane; tput rs1; echo -e \"\\033c\"; clear";
      # safety net when using mv
      mv = "mv -b -i";
      ls = "lsd";
      cat = "bat";
      grep = "rg";
      sudogui = "sudo -EH";
      # force scrollback clear on kitty
      clear = "clear -T xterm-256color";
      dust = "sudo dust -rx";
      discord = "discord --enable-features=UseOzonePlatform --ozone-platform=wayland";
    };
  };
}

