# # You can modify this part to get a different version of the compiler
# let
#   hash = "7731621c81b5cd601a176c2109b44c5295049f20";
#   cc = "gcc";
#   version = "5.4.0";
# in

# # You should not touch this part expect to add the package name of the compiler in buildInputs
# You can modify this part to get a different version of the compiler
let
  hash = "7731621c81b5cd601a176c2109b44c5295049f20";
  cc = "gcc";
  version = "5.4.0";
in

# You should not touch this part expect to add the package name of the compiler in buildInputs
let
  impurepkgs = import <nixpkgs> { };
  pkgs = import (impurepkgs.fetchzip {
    url = "https://github.com/nixos/nixpkgs/archive/${hash}.zip";
    # Please update this hash with the one nix says on the first build attempt
    sha256 = "0gdf2kkh3qcn9r300sl4khcg0fnixarjcil9pv9hami3dqjbpngv";}) {};
  stdenv = pkgs.pkgsi686Linux.stdenv;
in

stdenv.mkDerivation {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs.pkgsi686Linux; [ glibc.static ]; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile
  CC_VERSION = "${version}";
}
