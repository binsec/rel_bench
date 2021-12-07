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
# # gcc-4.9.3 not working
# # echo "------------------------------------------------"
# # nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-4.9.3.nix

# # gcc-5.4.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-5.4.0.nix

# gcc-6.2.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-6.2.0.nix
# With a hack because the linker does not work.
for version in O0 O1 O2 O3 witnessO3 no-dse no-tree-dse no-dse-all
do
    FILE=./bin/secret-erasure_EXPLICIT_BZERO_${version}_gcc_6.2.0
    if test -f ${FILE}.o; then
        echo "Linking $FILE"
        gcc -static -m32 ${FILE}.o -o ${FILE} -L./safeclib_bin/gcc_6.2.0 -lsafec-3.6.0 -L../__libsym__/ -lsym
        rm ${FILE}.o
    fi
done

# gcc-7.2.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-7.2.0.nix

# gcc-8.3.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-8.3.0.nix

# gcc-10.2.0
echo "------------------------------------------------"
nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./gcc-10.2.0.nix



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

exit 0

# ----------------------------------------------------
# The following compilers must be in you path
# Binary can be downloaded directly on clang's website  (here Ubuntu 64-bit).

# clang-3.0: opt does not work so no expes without -dse
echo "------------------------------------------------"
# nix-shell --run "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}" ./clang-3.0.0.nix
# Make sure clang 3.0 is in you path
export CC=clang-3.0
export CC_VERSION="3.0"
export OPT_VERSION="opt-3.0"
export OPT="" # opt-3.0 was not working
eval "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}"

# clang-3.9.0
echo "------------------------------------------------"
# Make sure clang 3.9  and opt-3.9 are in you path
export CC=clang-3.9
export CC_VERSION="3.9"
export OPT_VERSION="opt-3.9"
export OPT="-tti -tbaa -scoped-noalias -assumption-cache-tracker -targetlibinfo -verify -simplifycfg -domtree -sroa -early-cse -lower-expect -targetlibinfo -tti -tbaa -scoped-noalias -assumption-cache-tracker -profile-summary-info -forceattrs -inferattrs -ipsccp -globalopt -domtree -mem2reg -deadargelim -domtree -basicaa -aa -instcombine -simplifycfg -pgo-icall-prom -basiccg -globals-aa -prune-eh -inline -functionattrs -argpromotion -domtree -sroa -early-cse -speculative-execution -lazy-value-info -jump-threading -correlated-propagation -simplifycfg -domtree -basicaa -aa -instcombine -tailcallelim -simplifycfg -reassociate -domtree -loops -loop-simplify -lcssa -basicaa -aa -scalar-evolution -loop-rotate -licm -loop-unswitch -simplifycfg -domtree -basicaa -aa -instcombine -loops -loop-simplify -lcssa -scalar-evolution -indvars -loop-idiom -loop-deletion -loop-unroll -mldst-motion -aa -memdep -gvn -basicaa -aa -memdep -memcpyopt -sccp -domtree -demanded-bits -bdce -basicaa -aa -instcombine -lazy-value-info -jump-threading -correlated-propagation -domtree -basicaa -aa -memdep -loops -loop-simplify -lcssa -aa -scalar-evolution -licm -adce -simplifycfg -domtree -basicaa -aa -instcombine -barrier -elim-avail-extern -basiccg -rpo-functionattrs -globals-aa -float2int -domtree -loops -loop-simplify -lcssa -basicaa -aa -scalar-evolution -loop-rotate -loop-accesses -branch-prob -lazy-block-freq -opt-remark-emitter -loop-distribute -loop-simplify -lcssa -branch-prob -block-freq -scalar-evolution -basicaa -aa -loop-accesses -demanded-bits -loop-vectorize -loop-simplify -scalar-evolution -aa -loop-accesses -loop-load-elim -basicaa -aa -instcombine -scalar-evolution -demanded-bits -slp-vectorizer -simplifycfg -domtree -basicaa -aa -instcombine -loops -loop-simplify -lcssa -scalar-evolution -loop-unroll -instcombine -loop-simplify -lcssa -scalar-evolution -licm -instsimplify -scalar-evolution -alignment-from-assumptions -strip-dead-prototypes -globaldce -constmerge -verify -domtree"
eval "echo Compiling with \${CC}_\${CC_VERSION}; ${CMD}"
