# You can modify this part to get a different version of the compiler
let
  hash = "3d24ae9b4426bb8adfcb08de57be21fdf0a377f8";
  cc = "gcc";
  version = "7.2.0";
in

# You should not touch this part expect to add the package name of the compiler in buildInputs
let
  impurepkgs = import <nixpkgs> { };
  pkgs = import (impurepkgs.fetchzip {
    url = "https://github.com/nixos/nixpkgs/archive/${hash}.zip";
    # Please update this hash with the one nix says on the first build attempt
    sha256 = "125pwa18hkdr5cv2g0z76k0fs0mawkyp137c6avab6l8156ws3hd";}) {};
  stdenv = pkgs.pkgsi686Linux.stdenv;
in

stdenv.mkDerivation {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs.pkgsi686Linux; [ glibc.static ]; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile
  
  CC_VERSION = "${version}";
}
