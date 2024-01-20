{ pkgs, self, ... }: rec {
  font = {
    monospace = {
      package = pkgs.fira-code-nerdfont;
      name = "FiraCode Nerd Font";
      features = [
        "subpixel_antialias"
        "ss03"
        "ss05"
      ];
    };
  };
}
