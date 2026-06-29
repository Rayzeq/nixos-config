{ pkgs ? import <nixpkgs> { } }:
let
  cxx-qt-cmake = pkgs.fetchFromGitHub {
    owner = "kdab";
    repo = "cxx-qt-cmake";
    tag = "0.8.1";
    hash = "sha256-kXSIU71iHn+SSGikGoNeMbBpSrDJ6hwhnHslmskm8nY=";
  };
in
pkgs.stdenv.mkDerivation rec {
  name = "qml-rust-extensions";
  src = ./.;

  cargoDeps = pkgs.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake

    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = with pkgs; [
    (with pkgs.qt6; env
      "${name}-qt-${qtbase.version}"
      [
        qtbase
        qtdeclarative
      ]
    )
    libGL
    corrosion
    openssl_4_0
    onnxruntime
  ];

  dontWrapQtApps = true;

  cmakeFlags = [
    "--no-warn-unused-cli"
    "-DFETCHCONTENT_SOURCE_DIR_CXXQT=${cxx-qt-cmake}"
  ];

  installPhase = ''
    mkdir -p $out/lib/qt-6/qml

    cp -r RustExtensions $out/lib/qt-6/qml/
    cp -r librust_extensions.so $out/lib/qt-6/qml/RustExtensions/
  '';
}
