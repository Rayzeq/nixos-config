{ config, ... }: {
  kitty = {
    enable = true;

    clearScrollback = true;
    font = builtins.head config.fonts.monospace;
    keybindings = {
      "ctrl+c" = "combine : copy_or_interrupt : clear_selection";
      "ctrl+v" = "paste_from_clipboard";
      "ctrl+k" = "signal_child SIGKILL";
      "ctrl+t" = "new_tab_with_cwd";
      "ctrl+shift+t" = "new_tab";
      "ctrl+w" = "close_tab";
      "ctrl+alt+left" = "previous_tab";
      "ctrl+alt+right" = "next_tab";
      "ctrl+shift+left" = "move_tab_backward";
      "ctrl+shift+right" = "move_tab_forward";
      "ctrl+s" = "show_scrollback";
    };
    settings = {
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_title_max_length = 30;

      scrollback_pager = ''sh -c 'subl -n - && subl --command "set_file_type { \"syntax\": \"scope:text.ansi\" }"' '';
      scrollback_lines = 1000000000;

      color0 = "#222222";
      background_opacity = "0.8";
    };
  };
}
