{ lib, ... }: {
  git = {
    enable = true;
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
