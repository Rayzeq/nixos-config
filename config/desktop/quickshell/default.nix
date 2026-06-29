{ pkgs, ... }:
let
  quickshell = pkgs.quickshell.stdenv.mkDerivation {
    inherit (pkgs.quickshell) version meta;
    pname = "${pkgs.quickshell.pname}-wrapped";

    nativeBuildInputs = pkgs.quickshell.nativeBuildInputs ++ [ pkgs.qt6.wrapQtAppsHook ];
    buildInputs = pkgs.quickshell.buildInputs ++ [
      pkgs.kdePackages.kirigami
      (import ./rust { inherit pkgs; })
    ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      cp -r ${pkgs.quickshell}/* $out
    '';
  };
in
{
  hm.programs.quickshell = {
    enable = true;
    package = quickshell;

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

  hypr.land.settings.bindr = [
    "$mod, V, exec, ${quickshell}/bin/quickshell -c shell ipc call shell openClipboard"
  ];
}
