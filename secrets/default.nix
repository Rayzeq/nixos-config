{ agenix, pkgs, ... }: {
  environment.systemPackages = [ agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  age.secrets.password-zacharie = {
    file = ./password-zacharie.age;
    owner = "zacharie";
    group = "users";
  };
}
