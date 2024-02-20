{ pkgs, lib }:
with import <nixpkgs>
{
  overlays = [
    (import (fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
  ];
};
let
  rustPlatform = makeRustPlatform {
    cargo = rust-bin.stable.latest.minimal;
    rustc = rust-bin.stable.latest.minimal;
  };
in
rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "0.5.0";

  src = pkgs.fetchFromGitHub {
    owner = "elkowar";
    repo = "eww";
    rev = "387d344690903949121040f8a892f946e323c472";
    hash = "sha256-HBBz1NDtj2TnDK5ghDLRrAOwHXDZlzclvVscYnmKGck=";
  };

  cargoPatches = [
    ./custom-popover.patch
    ./string-truncation.patch
    ./tray3.patch
    ./completions.patch
  ];

  cargoHash = "sha256-B/wibyWbhztGnws4WFk+d9R6Ldxmc5BfoHo4763pFrQ=";

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
