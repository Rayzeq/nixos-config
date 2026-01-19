{ lib, ... }: {
  zsh = {
    enable = lib.mkDefault true;

    aliases = {
      fix = "reset; stty sane; tput rs1; echo -e \"\\033c\"; clear";
      # safety net when using mv
      mv = "mv -b -i";
      sudogui = "sudo -EH";
      dust = "sudo dust -rx";
      discord = "discord --enable-features=UseOzonePlatform --ozone-platform=wayland";
    };
  };
}

