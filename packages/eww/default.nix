{ ... }:
let
  pkgs = import <nixpkgs>
    {
      overlays = [
        (import (fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
      ];
    };
  rustPlatform = pkgs.makeRustPlatform {
    cargo = pkgs.rust-bin.stable.latest.minimal;
    rustc = pkgs.rust-bin.stable.latest.minimal;
  };
in
rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "0.5.0";

  src = pkgs.fetchFromGitHub {
    owner = "elkowar";
    repo = "eww";
    rev = "2c8811512460ce6cc75e021d8d081813647699dc";
    hash = "sha256-eDOg5Ink3iWT/B1WpD9po5/UxS4DEaVO4NPIRyjSheM=";
  };

  cargoPatches = [
    ./custom-popover.patch
  ];

  cargoHash = "sha256-yAkBfWI6UJJLAWeQEjqf31pklrlZEGbuEqhMnSM58BA=";

  nativeBuildInputs = with pkgs; [ pkg-config wrapGAppsHook installShellFiles ];

  buildInputs = with pkgs; [ gtk3 librsvg gtk-layer-shell libdbusmenu libdbusmenu-gtk3 ];

  buildNoDefaultFeatures = true;
  buildFeatures = [ "wayland" ];

  cargoBuildFlags = [ "--bin" "eww" ];

  cargoTestFlags = cargoBuildFlags;

  preFixup = ''
    installShellCompletion --cmd eww \
      --bash <($out/bin/eww shell-completions --shell bash) \
      --fish <($out/bin/eww shell-completions --shell fish) \
      --zsh <($out/bin/eww shell-completions --shell zsh) \
  '';
}
