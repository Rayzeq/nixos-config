{ pkgs, ... }: {
  sublime-text = {
    plugins = {
      Jinja2 = { };
      "HTML (Jinja)" = {
        managed = false;
        settings.extensions = [ "askama" ];
      };
      SublimeLinter.settings.linters.djlint = {
        executable = "${pkgs.djlint}/bin/djlint";
        # H006 - plain wrong
        # H013 - already handled, and better, by biome
        args = [ "--ignore" "H006,H013" ];
      };
      SublimeLinter-contrib-djlint = { };
      Fmt.settings = {
        rules = [
          {
            selector = "text.html.jinja";
            cmd = [ "${pkgs.djlint}/bin/djlint" "--reformat" "--quiet" "-" ];
            format_on_save = true;
            merge_type = "diff";
          }
        ];
      };
      # need to copy the whole default to add jinja
      LSP-biome.settings.selector = "source.js | source.ts | source.jsx | source.tsx | source.js.jsx | source.js.react | source.ts.react | source.astro | text.html.astro | source.css | source.scss | source.graphql | text.html.basic | text.html.svelte | text.html.vue | text.html.jinja";
      LSP-html.settings.selector = "text.html.basic | embedding.php | text.html.jinja";
    };
  };
}
