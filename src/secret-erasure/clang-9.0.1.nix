# You can modify this part to get a different version of the compiler
let
  pkgs = import <nixpkgs> {};
  cc = "clang";
  version = "9.0.1";
  stdenv = pkgs.pkgsi686Linux.llvmPackages_9.stdenv;
in

# You should not touch this part expect to add the package name of the compiler in buildInputs
stdenv.mkDerivation {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs.pkgsi686Linux; [ glibc.static ];

  # Set environment variables used in makefile
  CC_VERSION = "${version}";
}
