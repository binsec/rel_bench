# You can modify this part to get a different version of the compiler
let
  hash = "611258f063f9c1443a5f95db3fc1b6f36bbf4b52";
  cc = "gcc";
  version = "8.3.0";
in

# You should not touch this part expect to add the package name of the compiler in buildInputs
let
  pkgs64 = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${hash}.tar.gz") {};
  pkgs = pkgs64.pkgsi686Linux;
in
pkgs.mkShell {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs; [ glibc.static ]; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile

  CC_VERSION = "${version}";
}

# # You can modify this part to get a different version of the compiler
# let
#   pkgs = import <nixpkgs> {};
#   cc = "gcc";
#   version = "8.4.0";
#   stdenv = pkgs.pkgsi686Linux.gcc8Stdenv;
# in

# # You should not touch this part expect to add the package name of the compiler in buildInputs
# stdenv.mkDerivation {
#   name = "${cc}_${version}";
#   hardeningDisable = [ "all" ];
#   buildInputs = with pkgs.pkgsi686Linux; [ glibc.static ];

#   # Set environment variables used in makefile
#   CC_VERSION = "${version}";
# }
