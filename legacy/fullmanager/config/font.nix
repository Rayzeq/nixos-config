{ pkgs, ... }: {
  font = rec {
    sans-serif = with fonts; [ noto-sans unifont meslo-lgs-nf ];
    monospace = with fonts; [ fira-code meslo-lgs-nf ];

    fonts = {
      fira-code = {
        # We don't use the NerdFont version of Fira Code
        # because its icons are too small, by not using it
        # applications will load those glyphs from another font
        package = pkgs.fira-code;
        name = "Fira Code";
        type = "monospace";
        features = [
          "subpixel_antialias"
          "ss03"
          "ss05"
        ];
      };
      noto-sans = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
        type = "sans-serif";
      };
      unifont = {
        package = pkgs.unifont;
        name = "Unifont";
        type = "sans-serif";
      };
      meslo-lgs-nf = {
        package = pkgs.meslo-lgs-nf;
        name = "MesloLGS NF";
        type = "monospace";
      };
    };
  };
}
