{
  sublime-text = {
    build-systems."Python - Terminus" = {
      target = "terminus_open";
      cancel = "terminus_cancel_build";
      shell_cmd = ''python3 "''${file_path}/''${file_name}"; read -p "Press any key to continue..."'';
      working_dir = "$folder";
      selector = "source.python";
    };
    plugins = {
      LSP-ruff.settings.initialization_options.settings = {
        configurationPreference = "filesystemFirst";
        configuration = {
          target-version = "py314";
          lint = {
            future-annotations = true;
            select = [ "ALL" ];
            ignore = [
              # Ignore missing copyright notice
              "CPY"
            ];
          };
          format.nested-string-quote-style = "preferred";
        };
      };
      LSP-ty = { };
    };
  };
}
