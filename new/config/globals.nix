{ pkgs, self, ... }: rec {
  font = {
    monospace = {
      package = pkgs.fira-code;
      name = "Fira Code";
      features = [
        "subpixel_antialias"
        "ss03"
        "ss05"
      ];
    };
  };
}
