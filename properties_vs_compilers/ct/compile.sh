#!/usr/bin/bash

# --------- Choose the command to run in the nix-shell
GET_CC_VERSION="\${CC} --version"
GET_LIBC_VERSION="ldd --version"
# Command to compile safeclib library

if [ "${1}" = "cc-version" ]; then
    CMD="${GET_CC_VERSION}"
elif [ "${1}" = "libc-version" ]; then
    CMD="${GET_LIBC_VERSION}"
elif [ "${1}" = "safeclib" ]; then
    CMD="${MK_SAFECLIB}"
elif [ "${1}" = "help" ] || [ "${1}" = "-help" ] || [ "${1}" = "--help" ] || [ "${1}" = "" ]; then
    echo "Usage: ./compile.sh [ cc-version | libc-version | makefile_rule ]"
    exit 1
else
    CMD="make ${1}"
fi

# --------- Add you new compiler below
# # gcc-4.9.3 not working
# # echo "------------------------------------------------"
# # nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-4.9.3.nix

# # gcc-5.4.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./nix-scripts/gcc-5.4.0.nix

# gcc-6.2.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./nix-scripts/gcc-6.2.0.nix
# With a hack because the linker does not work.

# gcc-7.2.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./nix-scripts/gcc-7.2.0.nix

# gcc-8.3.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./nix-scripts/gcc-8.3.0.nix

# gcc-10.2.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./nix-scripts/gcc-10.2.0.nix



# clang-7.1.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./nix-scripts/clang-7.1.0.nix

# clang-9.0.1
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./nix-scripts/clang-9.0.1.nix

# clang-11.0.1
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./nix-scripts/clang-11.0.1.nix


# Cross-compiling with armv7l-unknown-linux-gnueabihf-gcc-10.2.0 -> Not working
echo "------------------------------------------------"
# nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMDARM}" ./nix-scripts/gcc-armv7.nix

exit 0

# ----------------------------------------------------
# The following compilers must be in you path
# Binary can be downloaded directly on clang's website  (here Ubuntu 64-bit).

# clang-3.0
echo "------------------------------------------------"
# Make sure clang 3.0 is in you path
export CC=clang-3.0
export CC_VERSION="3.0"
eval "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}"

# clang-3.9.0
echo "------------------------------------------------"
# Make sure clang 3.9  and opt-3.9 are in you path
export CC=clang-3.9
export CC_VERSION="3.9"
eval "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}"

# arm-linux-gnueabi-gcc (Ubuntu 10.3.0-1ubuntu1) 10.3.0
echo "------------------------------------------------"
# Make sure arm-linux-gnueabi-gcc is in you path
export CC=arm-linux-gnueabi-gcc
export CC_VERSION="10.3"
eval "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}"
