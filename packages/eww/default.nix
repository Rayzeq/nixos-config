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
    rev = "149727ce1f7dd4f461ab1d61d560546f3d1f32a1";
    hash = "sha256-DkJBMFUG8GLCoZ5yEXRDb4iWQjH+V6hrB4QQuRrn2F8=";
  };

  cargoPatches = [
    ./custom-popover.patch
    ./string-truncation.patch
  ];

  cargoHash = "sha256-zFzfGK31JoToJ5qupOu3d58IlrRmDMjc9pTKzmO680g=";

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
