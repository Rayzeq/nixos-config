{ pkgs, unstable, globals, ... }: {
  bettermanager.sublime-text = {
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
    };
    font = globals.font.monospace;
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
      {
        keys = [ "ctrl+=" ];
        command = "reset_font_size";
      }
      {
        keys = [ "f2" ];
        command = "lsp_symbol_rename";
        context = [
          {
            key = "lsp.session_with_capability";
            operand = "renameProvider";
          }
        ];
      }
      {
        keys = [ "ctrl+alt+left" ];
        command = "prev_view";
      }
      {
        keys = [ "ctrl+alt+right" ];
        command = "next_view";
      }
    ];
    build-systems."Python - Terminus" = {
      target = "terminus_open";
      cancel = "terminus_cancel_build";
      shell_cmd = ''python3 "''${file_path}/''${file_name}"; read -p "Press any key to continue..."'';
      working_dir = "$folder";
      selector = "source.python";
    };
    plugins = {
      ANSIescape = { };
      AutoFoldCode = { };
      BracketHighlighter = { };
      DoxyDoxygen = { };
      LiveServer.settings = {
        node_executable_path = "${pkgs.nodejs}/bin/node";
        global_node_modules_path = "${pkgs.nodePackages.live-server}/lib/node_modules";
      };
      LSP.settings = {
        lsp_format_on_save = true;
        lsp_code_actions_on_save.source = {
          fixAll = true;
          addMissingImports = true;
          organizeImports = true;
        };
        show_inlay_hints = true;
        default_clients = { };
        clients.nixd = {
          enabled = true;
          command = [ "${unstable.nixd}/bin/nixd" ];
          selector = "source.nix";
        };
      };
      LSP-bash = { };
      LSP-clangd.settings = {
        binary = "custom";
        initializationOptions.custom_command = [ "${pkgs.clang-tools}/bin/clangd" ];
      };
      LSP-copilot.settings = {
        command = [ "${pkgs.nodejs}/bin/node" "\${server_path}" "--stdio" ];
        settings.hook_to_auto_complete_command = true;
      };
      LSP-css = { };
      LSP-html.settings = {
        settings.html.format = {
          indentHandlebars = true;
          templating = true;
        };
      };
      LSP-json.settings = { };
      LSP-marksman.settings = {
        command = [ "${pkgs.marksman}/bin/marksman" ];
      };
      LSP-pylsp.settings = {
        env = {
          PYTHONPATH = "\${sublime_py_files_dir}\${pathsep}\${packages}:/home/zacharie/.nix-profile/lib/python3.11/site-packages/";
          MYPYPATH = "\${sublime_py_files_dir}\${pathsep}\${packages}:/home/zacharie/.nix-profile/lib/python3.11/site-packages/";
        };
        command = [ "steam-run" "$server_path" ];
        settings.pylsp.plugins = {
          jedi_completion.enabled = true;
          jedi_definition.enabled = true;
          jedi_hover.enabled = true;
          jedi_references.enabled = true;
          jedi_signature_help.enabled = true;
          jedi_symbols.enabled = true;
          pycodestyle.enabled = false;
          mccabe.enabled = false;
          # Crash pylsp
          # I think it's because it execute external code which comes from python2
          #rope_autoimport.enabled = true;
          autopep8.enabled = false;
          pylsp_mypy = {
            enabled = true;
            strict = true;
          };
          # Ruff config
          ruff = {
            enabled = true;
            lineLength = 120;
            select = [
              "F"
              "E"
              "W"
              "C90"
              "I"
              "N"
              "D"
              "UP"
              "YTT"
              "ANN"
              "ASYNC"
              "S"
              "BLE"
              "FBT"
              "B"
              "A"
              "COM"
              #"CPY"
              "C4"
              "DTZ"
              "T10"
              "DJ"
              "EM"
              "EXE"
              "FA"
              "ISC"
              "ICN"
              "G"
              #"INP"
              "PIE"
              "T20"
              "PYI"
              "PT"
              "Q"
              "RSE"
              "RET"
              "SLF"
              "SLOT"
              "SIM"
              "TID"
              "TCH"
              "INT"
              "ARG"
              "PTH"
              "TD"
              "FIX"
              "ERA"
              "PD"
              "PGH"
              "PL"
              "TRY"
              "FLY"
              "NPY"
              "AIR"
              "PERF"
              "FURB"
              "LOG"
              "RUF"
            ];
            format = [
              "F"
              "E"
              "W"
              "I"
              "D"
              "UP"
              "ANN"
              "B"
              "COM"
              "C4"
              "EM"
              "EXE"
              "ISC"
              "ICN"
              "G"
              "PIE"
              "PYI"
              "PT"
              "Q"
              "RSE"
              "RET"
              "SIM"
              "TID"
              "TCH"
              "PTH"
              "TD"
              "ERA"
              "PD"
              "PL"
              "TRY"
              "FLY"
              "NPY"
              "PERF"
              "FURB"
              "LOG"
              "RUF"
            ];
            ignore = [
              # Ignore missing docstrings
              "D100"
              "D101"
              "D102"
              "D103"
              "D104"
              "D105"
              "D106"
              "D107"
              # Remove "docstring should be in imperative mood"
              "D401"
              # Allow print
              "T201"
              # Allow commented out code
              "ERA001"
              # Allow useless else after return
              "RET505"
              # Remove warnings for nixos shebang
              "EXE003"
              "EXE005"
              # Allow private member access
              "SLF001"
              # Allow builtin shadowing
              "A003"
            ];
          };
          # Black config
          pylsp_black.enabled = true;
          black.line_length = 120;
        };
      };
      LSP-rust-analyzer.settings = {
        command = [ "${pkgs.rust-analyzer}/bin/rust-analyzer" ];
        settings.rust-analyzer = {
          assist.emitMustUse = true;
          cargo.features = "all";
          check.command = "clippy";
          check.extraArgs = [
            "--"
            "-W"
            "clippy::pedantic"
            "-W"
            "clippy::cargo"
            "-W"
            "clippy::nursery"
            #"-W"
            #"missing_docs"
            #"-W"
            # "clippy::missing_docs_in_private_items"
            #"-W", "clippy::std_instead_of_core"
            #"-W", "clippy::std_instead_of_alloc"
            "-W"
            "clippy::alloc_instead_of_core"
            "-W"
            "missing_debug_implementations"
            "-W"
            "clippy::expect_used"
            "-A"
            "clippy::cast_lossless"
            "-A"
            "clippy::redundant_else"
            # Annoying clippy :)
            #"-W", "clippy::all"
            #"-W", "clippy::restriction"
            #"-A", "clippy::implicit_return"
            #"-A", "clippy::question_mark_used"
            #"-A", "clippy::exhaustive_structs"
            #"-A", "clippy::missing_inline_in_public_items"
          ];
        };
      };
      LSP-typescript = { };
      Nix = { };
      SublimeRandomCrap = {
        repository = "https://github.com/facelessuser/SublimeRandomCrap";
      };
      Terminus = { };
      TOML = { };
      HTML = {
        managed = false;
        settings.extensions = [ "hbs" ];
      };
      SCSS = { };
    };
  };
}
