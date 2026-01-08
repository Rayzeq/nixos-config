{ lib, ... }: {
  git = {
    enable = lib.mkDefault true;
    settings = {
      user = {
        name = "Zacharie Dubrulle";
        email = "dubrullezacharie@gmail.com";
      };
      alias = {
        forget = "!git rm -r --cached . && git add . && :";
      };
    };
  };
}
