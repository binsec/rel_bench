# You can modify this part to get a different version of the compiler
let
  hash = "9f3fe63b5f491db8a2b9daf20d4cdd4f13623542";
  cc = "gcc";
  version = "4.9.3";
in

let
  pkgs = import <nixpkgs> { };

  # Version: 4.9.3
  stdenv = (import (pkgs.fetchzip {
    url = "https://github.com/nixos/nixpkgs/archive/${hash}.zip";
    # Please update this hash with the one nix says on the first build attempt
    sha256 = "1p5mb8g2ri0i1ycz35jfsc0y8s4n2difyvf7agjmrzpizvp46k9p";
  }) { }).pkgsi686Linux.stdenv;
in

stdenv.mkDerivation {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = [ pkgs.pkgsCross.musl32 ] ; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile
  
  CC_VERSION = "${version}";
}
