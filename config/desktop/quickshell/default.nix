{ pkgs, ... }: {
  hm.programs.quickshell = {
    enable = true;

    systemd.enable = true;
    activeConfig = "shell";
    configs.shell = pkgs.stdenv.mkDerivation {
      name = "shell";
      src = ./.;
      buildInputs = with pkgs; [
        rsync
        kdePackages.qtshadertools
      ];
      dontWrapQtApps = true;

      buildPhase = ''
        for file in $(find . -name '*.frag');
        do
          qsb --qt6 "$file" -o "$file.qsb"
        done
      '';
      installPhase = ''
        mkdir -p $out/
        mkdir -p $out/assets/image/
        cp ${../hypr/wallpapers/light.png} $out/assets/image/background.png
        rsync -r --exclude '*.frag' --exclude '*.nix' --exclude .envrc . $out/
      '';
    };
  };
  system.security.pam.services.quickshell = { };
}
