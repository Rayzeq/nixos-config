{ lib, ... }: {
  sublime-merge = {
    enable = lib.mkDefault true;

    settings = {
      diff_style = "auto";
      added_words = [
        "gitignore"
        "installable"
        "whitespace"
        "hardcoded"
      ];
    };
  };
}
