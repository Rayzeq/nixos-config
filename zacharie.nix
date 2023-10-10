{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.zacharie = {
    home.stateVersion = "23.05";

    programs.git = {
      enable = true;
      userName = "Zacharie Dubrulle";
      userEmail = "dubrullezacharie@gmail.com";
    };

    programs.zsh = {
      enable = true;
      history.share = false;
      shellAliases = {
        fix = "reset; stty sane; tput rs1; echo -e \"\\033c\"; clear";
        # safety net when using mv
        mv = "mv -b -i";
        ls = "lsd";
        cat = "bat";
        grep = "rg";
        unilim = "sudo openfortivpn u-vpn.unilim.fr -u dubrulle3 -p @Zacharie36";
      };

      # Powerlevel10k configuration
      initExtraFirst = ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      initExtra = ''
        source ~/.p10k.zsh
      '';
    };

    services.barrier.client = {
      enable = true;
      enableCrypto = true;
      enableDragDrop = true;
      server = "192.168.0.109";
    };
  };
}
