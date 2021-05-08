# You can modify this part to get a different version of the compiler
let
  hash = "7138a338b58713e0dea22ddab6a6785abec7376a";
  cc = "clang";
  version = "7.1.0";
in

# You should not touch this part expect to add the package name of the compiler in buildInputs
let
  pkgs64 = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${hash}.tar.gz") {};
  pkgs = pkgs64.pkgsi686Linux;
in
pkgs.clangStdenv.mkDerivation {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs; [ clang glibc.static ]; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile
  
  CC_VERSION = "${version}";
}
