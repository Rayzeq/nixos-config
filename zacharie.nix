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
      aliases = {
        forget = "!git rm -r --cached . && git add . && :";
      };
    };

    programs.zsh = {
      enable = true;
      history.share = false;
      autocd = true;
      shellAliases = {
        fix = "reset; stty sane; tput rs1; echo -e \"\\033c\"; clear";
        # safety net when using mv
        mv = "mv -b -i";
        ls = "lsd";
        cat = "bat";
        grep = "rg";
        unilim = "sudo openfortivpn u-vpn.unilim.fr -u dubrulle3 -p @Zacharie36";
        system-update = "sudo zsh -c \"nix-channel --update unstable; nixos-rebuild switch --upgrade\"";
      };

      # Powerlevel10k configuration
      initExtraFirst = ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      initExtra = ''
        source ~/.p10k.zsh
        bindkey '^H' backward-kill-word
        bindkey '5~' kill-word
        bindkey '^K' backward-kill-line

        ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      '';
    };

    services.barrier.client = {
      enable = true;
      enableCrypto = true;
      enableDragDrop = true;
      server = "10.42.0.48";
    };

    xdg.configFile."sublime-text/Packages/User/LiveServer.sublime-settings".text = "
      {
        \"node_executable_path\": \"${pkgs.nodejs}/bin/node\",
        \"global_node_modules_path\": \"${pkgs.nodePackages.live-server}/lib/node_modules\",
      }
    ";
  };
}
