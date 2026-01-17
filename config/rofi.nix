{ pkgs, lib, globals, config, ... }:
let
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  rofi = {
    enable = lib.mkDefault true;
    plugins = with pkgs; [ rofi-games ];

    config = {
      launcher = {
        show = "combi";
        modes = [ "combi" ];

        combi-modes = [ "drun" "games" ];
        display-combi = "";
        combi-display-format = "{text}";

        drun-match-fields = [ "name" "exec" ];
        drun-display-format = "{name} [<span weight='light' size='small'><i>({exec})</i></span>]";

        show-icons = true;
        terminal = "kitty";
      };
      clipboard = {
        show = "dmenu";

        display-columns = 2;
        p = "Clipboard";
      };
    };

    theme = {
      configuration = {
        hover-select = true;
        me-select-entry = "";
        me-accept-entry = "MousePrimary";
      };

      "*" = {
        text-color = mkLiteral "white";
        background-color = mkLiteral "transparent";
      };

      window = {
        border-radius = mkLiteral "20px";
        padding = mkLiteral "10px";

        font = "Fira Code 15";
        background-color = mkLiteral globals.overlay-background;
      };

      inputbar = {
        margin = mkLiteral "5px";
        spacing = mkLiteral "5px";
      };

      listview = {
        cycle = false;
        scrollbar = true;
      };

      scrollbar = {
        handle-width = mkLiteral "3px";
        handle-color = mkLiteral "gray";
      };

      element = {
        margin = mkLiteral "2px 5px";
        border-radius = mkLiteral "8px";
        padding = mkLiteral "5px";
        spacing = mkLiteral "10px";
      };

      "element selected.normal" = {
        text-color = mkLiteral "black";
        background-color = mkLiteral "#5f6f90";
      };

      element-icon = {
        size = mkLiteral "24px";
      };
    };
  };
}
