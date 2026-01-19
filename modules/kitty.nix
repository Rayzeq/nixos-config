{ home-manager, lib, pkgs, config, hmConfig, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.kitty;

  kittyOptions = lib.getOptions "${home-manager}/modules/programs/kitty.nix";

  postscriptNames = pkgs.runCommand "get-postscript-names"
    {
      nativeBuildInputs = [ pkgs.fontconfig ];
      FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ cfg.font.package ]; };
    }
    ''
      ${pkgs.fontconfig}/bin/fc-list "${cfg.font.name}" -f "%{postscriptname}\n" | ${pkgs.coreutils}/bin/sort -u | ${pkgs.gnugrep}/bin/grep -v "^$" | ${pkgs.coreutils}/bin/head -c -1 > $out
    '';
  namesList = lib.splitString "\n" (builtins.readFile postscriptNames);
in
{
  options.kitty = {
    inherit (kittyOptions) enable package settings keybindings;

    font = mkOption {
      type = types.nullOr config.lib.types.font;
      default = null;
      description = ''
        The font to use.
      '';
    };

    clearScrollback = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Make the `clear` command also clear the scrollback buffer.
      '';
    };
  };

  config.hm = mkIf cfg.enable {
    programs.kitty = {
      inherit (cfg) enable package settings keybindings;
      font = mkIf (cfg.font != null) {
        inherit (cfg.font) package name;
      };
      extraConfig = lib.concatMapStringsSep "\n"
        (name:
          "font_features ${name} ${lib.concatMapStringsSep " " (feature: "+${feature}") cfg.font.features}"
        )
        namesList;
    };
    home.packages = lib.mkIf cfg.clearScrollback [
      (pkgs.runCommand "kitty-terminfo-patch"
        {
          nativeBuildInputs = [ pkgs.ncurses ];
          TERMINFO_DIRS = "${pkgs.kitty.terminfo}/share/terminfo";
          # priority higher (numerically lower) than default, so our terminfo override's
          # kitty's one
          meta.priority = 4;
        } ''
        mkdir -p $out/share/terminfo

        # decompile current config to text
        infocmp -x xterm-kitty > source.ti

        # add E3 (clear scrollback) capability
        echo '  E3=\E[3J,' >> source.ti

        # recompile modified config to terminfo db
        tic -x -o $out/share/terminfo source.ti
      '')
    ];
    programs.zsh.initContent = lib.mkIf
      (cfg.clearScrollback && hmConfig.programs.kitty.shellIntegration.enableZshIntegration)
      (lib.mkAfter ''
        unset TERMINFO
      '');
  };
}
