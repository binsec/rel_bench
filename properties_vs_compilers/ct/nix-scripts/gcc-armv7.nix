# You can modify this part to get a different version of the compiler
let
  cc = "armv7l-unknown-linux-gnueabihf-gcc";
  version = "10.2.0";
in

let pkgs = import <nixpkgs> {
    crossSystem = (import <nixpkgs/lib>).systems.examples.armv7l-hf-multiplatform;
    };
in
crossSystem.mkShell {
  name = "${cc}_${version}";
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs; [ glibc.static ]; # don't forget to add gcc or clang here !

  # Set environment variables used in makefile
  CC_VERSION = "${version}";
  LC_ALL="C";

}
