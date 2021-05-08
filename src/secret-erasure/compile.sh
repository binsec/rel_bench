#!/usr/bin/bash

# --------- Choose the command to run in the nix-shell
GET_CC_VERSION="\${CC} --version"
GET_LIBC_VERSION="ldd --version"
# Command to compile safeclib library
MK_SAFECLIB="cd safeclib && ./build-aux/autogen.sh && ./configure --host=x86_64-pc-linux-gnu --build=i686-pc-linux-gnu CFLAGS=\"-m32 -Wno-error=implicit-function-declaration -Wno-error=nested-externs\" CXXFLAGS=-m32 LDFLAGS=-m32 && make && mkdir -p ../safeclib_bin/\${CC}_\${CC_VERSION}/ && mv src/.libs/libsafec-3.6.0.a ../safeclib_bin/\${CC}_\${CC_VERSION}; cd .."

if [ "${1}" = "cc-version" ]; then
    CMD="${GET_CC_VERSION}"
elif [ "${1}" = "libc-version" ]; then
    CMD="${GET_LIBC_VERSION}"
elif [ "${1}" = "safeclib" ]; then
    CMD="${MK_SAFECLIB}"
elif [ "${1}" = "help" ] || [ "${1}" = "-help" ] || [ "${1}" = "--help" ] || [ "${1}" = "" ]; then
    echo "Usage: ./compile.sh [ cc-version | libc-version | safelibc | makefile_rule ]"
    exit 1
else
    CMD="make ${1}"
fi


# --------- Add you new compiler below

# gcc-4.9.3 not working
# echo "------------------------------------------------"
# nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-4.9.3.nix

# gcc-5.4.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-5.4.0.nix

# gcc-6.2.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-6.2.0.nix

# gcc-7.2.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-7.2.0.nix

# gcc-8.3.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-8.3.0.nix

# gcc-10.2.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-10.2.0.nix

# clang-3.0
echo "------------------------------------------------"
# nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./clang-3.0.0.nix
# Make sure clang 3.0 is in you path
export CC=clang-3.0
export CC_VERSION="3.0"
eval "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}"

# # clang-3.3
# echo "------------------------------------------------"
# # Make sure clang 3.3 is in you path
# export CC=clang-3.3
# export CC_VERSION="3.3"
# eval "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}"

# clang-3.9.0
echo "------------------------------------------------"
# Make sure clang 3.9 is in you path
export CC=clang-3.9
export CC_VERSION="3.9"
eval "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}"

# clang-7.1.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./clang-7.1.0.nix

# clang-9.0.1
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./clang-9.0.1.nix

# clang-11.0.1
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./clang-11.0.1.nix


# Cross-compiling with armv7l-unknown-linux-gnueabihf-gcc-10.2.0
echo "------------------------------------------------"
# nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMDARM}" ./gcc-armv7.nix
