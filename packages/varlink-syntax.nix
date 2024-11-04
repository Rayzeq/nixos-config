{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "varlink-syntax";

  src = pkgs.fetchFromGitHub {
    owner = "varlink";
    repo = "syntax-highlight-varlink";
    rev = "04f30d4b831232ea23ffceb5b2da61e12dae5db6";
    sha256 = "sha256-TyilZCh+PEct36wcquOaETd4BBeZlRRMXakfvYqyfv8=";
  };

  installPhase = ''
    mkdir $out
    cp -rv $src/* $out
  '';
}
