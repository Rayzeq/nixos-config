{ pkgs, ... }: {
  font = {
    sans = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
      fallbacks = [
        {
          name = "Unifont";
          package = pkgs.unifont;
        }
        # We install Meslo LGS NerdFont so apps will use it as a
        # fallback for NerdFont icons
        {
          name = "MesloLGS NF";
          package = pkgs.meslo-lgs-nf;
        }
      ];
    };
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
        {
          name = "MesloLGS NF";
          package = pkgs.meslo-lgs-nf;
        }
      ];
    };
  };
}
