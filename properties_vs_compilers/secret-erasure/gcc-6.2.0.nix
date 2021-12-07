# You can modify this part to get a different version of the compiler
let
  hash = "a399c55a0f45381e0581597bc87700134d059de6";
  cc = "gcc";
  version = "6.2.0";
in

# You should not touch this part expect to add the package name of the compiler in buildInputs
let
  impurepkgs = import <nixpkgs> { };
  pkgs = import (impurepkgs.fetchzip {
    url = "https://github.com/nixos/nixpkgs/archive/${hash}.zip";
    # Please update this hash with the one nix says on the first build attempt
    sha256 = "15f014cn7bl6adi6dgns8z96nlv4f8wxmy45zn06isdnp0z5qi2c";}) {};
  stdenv = pkgs.pkgsi686Linux.stdenv;
in

stdenv.mkDerivation {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs.pkgsi686Linux; [ glibc.static ]; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile
  
  CC_VERSION = "${version}";
}
