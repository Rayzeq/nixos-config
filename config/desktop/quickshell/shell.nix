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
in
pkgs.mkShell {
  packages = with pkgs; [
    quickshell
    kdePackages.qtdeclarative
    inotify-tools
  ];
  shellHook = ''
    # Required for qmlls to find the correct type declarations
    export QMLLS_BUILD_DIRS=${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml/:${pkgs.quickshell}/lib/qt-6/qml/
    export QML_IMPORT_PATH=$PWD/src
    export PATH=$PATH:${shaderWatch}/bin
  '';
}
