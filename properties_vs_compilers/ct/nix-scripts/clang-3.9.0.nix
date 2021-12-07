# You can modify this part to get a different version of the compiler
let
  hash = "948f4a9c6d15a9f5380ea23a5292fdc503804e44";
  cc = "clang";
  version = "3.9.0";
in

let
  pkgs = import <nixpkgs> { };

  clangStdenv = (import (pkgs.fetchzip {
    url = "https://github.com/nixos/nixpkgs/archive/${hash}.zip";
    sha256 = "1p5mb8g2ri0i1ycz35jfsc0y8s4n2difyvf7agjmrzpizvp46k9p";
  }) { }).pkgsi686Linux.clangStdenv;
in

clangStdenv.mkDerivation {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs.pkgsi686Linux; [ glibc.static ]; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile

  CC_VERSION = "${version}";
}
