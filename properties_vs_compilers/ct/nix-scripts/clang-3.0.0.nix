# You can modify this part to get a different version of the compiler
let
  hash = "cd83eb3173e92deb67596d724f6aad6984145490";
  cc = "clang";
  version = "3.0";
in

let
  impurepkgs = import <nixpkgs> { };
  # Version: 3.0
  pkgs = import (impurepkgs.fetchzip {
    url = "https://github.com/nixos/nixpkgs/archive/${hash}.zip";
    # Please update this hash with the one nix says on the first build attempt
    sha256 = "04ajcvp2ziy88n80qn8xi43jyqfc9cm1jn4nj0f37w5kn5dgf7mp";}) {};
  stdenv = pkgs.pkgsi686Linux.clangStdenv;
in

stdenv.mkDerivation {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  # buildInputs = with pkgs.pkgsi686Linux; [ glibc.static ]; # don't forget to add gcc or clang here !
  buildInputs = with pkgs.pkgsi686Linux; [ glibc ]; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile
  
  CC_VERSION = "${version}";
  LC_ALL="C";
}
