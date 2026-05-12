{ pkgs, config, ... }: {
  sublime-text = {
    enable = true;

    settings = {
      theme = "Adaptive.sublime-theme";
      color_scheme = "Monokai.sublime-color-scheme";
      show_encoding = true;
      show_line_endings = true;
      copy_with_empty_selection = false;
      ignored_packages = [ "Vintage" ];
      relative_line_numbers = true;
      index_files = true;
      "disable_plugin_host_3.3" = true;
    };
    font = builtins.head config.fonts.monospace;
    keymap = [
      {
        keys = [ "ctrl+alt+up" ];
        command = "select_lines";
        args.forward = false;
      }
      {
        keys = [ "ctrl+alt+down" ];
        command = "select_lines";
        args.forward = true;
      }
      {
        keys = [ "ctrl+keypad_divide" ];
        command = "toggle_comment";
        args.block = false;
      }
      {
        keys = [ "ctrl+shift+keypad_divide" ];
        command = "toggle_comment";
        args.block = true;
      }
      {
        keys = [ "ctrl+5" ];
        command = "bh_key";
        args.plugin.command = "bh_modules.foldbracket";
      }
      # Select text between brackets
      {
        no_outside_adj = null;
        keys = [ "ctrl+shift+5" ];
        command = "bh_key";
        args = {
          lines = true;
          plugin.command = "bh_modules.bracketselect";
        };
      }
      {
        keys = [ "ctrl+alt+5" ];
        command = "swap_brackets";
      }
      {
        keys = [ "ctrl+=" ];
        command = "reset_font_size";
      }
      {
        keys = [ "f2" ];
        command = "lsp_symbol_rename";
        context = [{
          key = "lsp.session_with_capability";
          operand = "renameProvider";
        }];
      }
      {
        keys = [ "ctrl+alt+left" ];
        command = "prev_view";
      }
      {
        keys = [ "ctrl+alt+right" ];
        command = "next_view";
      }
      {
        keys = [ "ctrl+shift+k" ];
        command = "open_terminal";
      }
      {
        keys = [
          "ctrl+alt+shift+left"
        ];
        command = "move_tab";
        args = {
          position = "-1";
        };
      }
      {
        keys = [
          "ctrl+alt+shift+right"
        ];
        command = "move_tab";
        args = {
          position = "+1";
        };
      }
    ];
    snippets.nix-shell = {
      content = ''
        { pkgs ? import <nixpkgs> {} }:
        pkgs.mkShell {
          nativeBuildInputs = with pkgs.buildPackages; [
            $1
          ];
          shellHook = '''
            $2
          ''';
        }
      '';
      tabTrigger = "shell";
      scope = "source.nix";
    };
    plugins = {
      ANSIescape = { };
      AutoFoldCode = { };
      BracketHighlighter = { };
      DoxyDoxygen = { };
      LSP.settings = {
        inhibit_word_completions = true;
        lsp_format_on_save = true;
        lsp_code_actions_on_save = {
          "source.fixAll" = true;
          "source.addMissingImports" = true;
          "source.organizeImports" = true;
        };
        show_inlay_hints = true;
        semantic_highlighting = true;
      };
      LanguageServers = {
        managed = false;
        settings.nixd = {
          enabled = true;
          command = [ "${pkgs.nixd}/bin/nixd" ];
          selector = "source.nix";
          settings.nixd.formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
        };
      };
      LSP-bash = { };
      LSP-clangd.settings = {
        binary = "custom";
        initializationOptions.custom_command = [ "${pkgs.clang-tools}/bin/clangd" ];
      };
      LSP-css = { };
      LSP-html.settings = {
        settings.html.format = {
          indentHandlebars = true;
          templating = true;

          wrapAttributes = "preserve";
        };
      };
      LSP-json.settings = { };
      LSP-marksman.settings.command = [ "${pkgs.marksman}/bin/marksman" ];
      LSP-rust-analyzer.settings = {
        command = [ "${pkgs.rustup}/bin/rust-analyzer" ];
        settings.rust-analyzer = {
          assist.emitMustUse = true;
          check.command = "clippy";
          check.extraArgs = [
            "--"
            "-W"
            "clippy::pedantic"
            "-W"
            "clippy::cargo"
            "-W"
            "clippy::nursery"
            #"-W" "missing_docs"
            #"-W" "clippy::missing_docs_in_private_items"
            #"-W" "clippy::std_instead_of_core"
            #"-W" "clippy::std_instead_of_alloc"
            "-W"
            "clippy::alloc_instead_of_core"
            "-W"
            "missing_debug_implementations"
            "-W"
            "clippy::todo"
            "-W"
            "clippy::clone_on_ref_ptr"
            "-W"
            "clippy::unwrap_used"
            "-W"
            "clippy::allow_attributes_without_reason"

            "-A"
            "clippy::missing_errors_doc"
            # Annoying clippy :)
            #"-W" "clippy::all"
            #"-W" "clippy::restriction"
            #"-A" "clippy::implicit_return"
            #"-A" "clippy::question_mark_used"
            #"-A" "clippy::exhaustive_structs"
            #"-A" "clippy::missing_inline_in_public_items"
          ];
        };
      };
      LSP-typescript.settings.settings.typescript = {
        format = {
          semicolons = "insert";
        };
        inlayHints = {
          includeInlayFunctionParameterTypeHints = true;
          includeInlayFunctionLikeReturnTypeHints = true;
          includeInlayParameterNameHints = "literals";
          includeInlayVariableTypeHints = true;
        };
      };
      LSP-lemminix = { };
      Debugger = { };
      Nix = { };
      SublimeRandomCrap.repository = "https://github.com/facelessuser/SublimeRandomCrap";
      Terminus = { };
      Terminal.settings.terminal = "kitty";
      Sass = { };
      FileIcons = { };
      MoveTab = { };
      HTML = {
        managed = false;
        settings.extensions = [ "hbs" ];
      };
      JavaScript = {
        managed = false;
        overrides."Fold.tmPreferences" = ./JS_Fold.tmPreferences;
      };
      Rust = {
        managed = false;
        overrides."Fold.tmPreferences" = ./Rust_Fold.tmPreferences;
      };
    };
  };
}
