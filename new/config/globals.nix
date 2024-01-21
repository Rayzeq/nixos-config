{ pkgs, self, ... }: rec {
  font = {
    monospace = {
      # We don't use the NerdFont version of Fira Code
      # because its icons are too small, by not using it
      # applications will load those glyphs from another font
      package = pkgs.fira-code;
      name = "Fira Code";
      features = [
        "subpixel_antialias"
        "ss03"
        "ss05"
      ];
      fallbacks = [
        # We install Meslo LGS NerdFont so apps will use it as a
        # fallback for NerdFont icons
        pkgs.meslo-lgs-nf
      ];
    };
  };
}
