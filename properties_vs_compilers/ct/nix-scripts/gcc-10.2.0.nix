# You can modify this part to get a different version of the compiler
let
  hash = "bf46afde6b22942ea605983f66ee23038986ba07";
  cc = "gcc";
  version = "10.2.0";
in

# You should not touch this part expect to add the package name of the compiler in buildInputs
let
  pkgs64 = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${hash}.tar.gz") {};
  pkgs = pkgs64.pkgsi686Linux;
in
pkgs.mkShell {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs; [ gcc glibc.static ]; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile
  
  CC_VERSION = "${version}";
}
