{ pkgs ? import <nixpkgs> { }, ... }:
let
  shaderWatch = pkgs.writeShellScriptBin "watch-shaders" ''
    quickshell -p test.qml &
    quickshell_pid=$!

    inotifywait -m -e modify -e move -e create --include '.*\.(frag|vert)$' "./assets/shader" |
    while read -r directory events filename; do
      echo "Skipping $(timeout 0.1 cat | wc -l) further changes"

      filepath="$directory$filename"
      outfile="''${filepath}.qsb"

      qsb --qt6 "$filepath" -o "$outfile"

      if [ $? -eq 0 ]; then
        echo "✅ Success: Generated $outfile"
      else
        echo "❌ Error: Failed to compile $filename"
      fi

      kill $quickshell_pid
      quickshell -p test.qml &
      quickshell_pid=$!
    done
  '';

  quickshellWrapper = pkgs.quickshell.stdenv.mkDerivation
    {
      inherit (pkgs.quickshell) version meta buildInputs;
      pname = "${pkgs.quickshell.pname}-wrapped";

      nativeBuildInputs = pkgs.quickshell.nativeBuildInputs ++ [ pkgs.qt6.wrapQtAppsHook ];

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        mkdir -p $out
        cp -r ${pkgs.quickshell}/* $out
      '';

      passthru = {
        unwrapped = pkgs.quickshell;
        withModules = modules: quickshellWrapper.overrideAttrs (prev: {
          buildInputs = prev.buildInputs ++ modules;
        });
      };
    };

  rustExtensions = import ./rust { inherit pkgs; };
  qmlModules = with pkgs; [
    qt6.qtdeclarative
    quickshell
    kdePackages.kirigami.unwrapped
    rustExtensions
  ];
  qmlImportPath = pkgs.lib.makeSearchPath "lib/qt-6/qml" qmlModules;
in
pkgs.mkShell {
  inputsFrom = [ rustExtensions ];

  packages = with pkgs; [
    (quickshellWrapper.withModules [ kdePackages.kirigami rustExtensions ])
    inotify-tools
    shaderWatch
    rust-analyzer
    clippy
  ];

  env = {
    QMLLS_BUILD_DIRS = qmlImportPath;
    QT_LOGGING_RULES = "qt.qml.usedbeforedeclared.warning=false";
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}
