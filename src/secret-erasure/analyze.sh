#!/usr/bin/bash
#
# Run binsec on a set of binary files and check whether they enforce
# secret-erasure or if they fail to scrub secret-data from memory.


# -------- Configure which binary files to analyze
#
# Add you new scrubbing function here
SCRUBBING_FUNCTIONS="LOOP MEMSET BZERO EXPLICIT_BZERO MEMSET_S VOLATILE_FUNC \
    PTR_TO_VOLATILE_LOOP PTR_TO_VOLATILE_MEMSET VOLATILE_PTR_LOOP VOLATILE_PTR_MEMSET \
    VOL_PTR_TO_VOL_LOOP VOL_PTR_TO_VOL_MEMSET \
    MEMORY_BARRIER_SIMPLE MEMORY_BARRIER_MFENCE MEMORY_BARRIER_LOCK MEMORY_BARRIER_PTR \
    WEAK_SYMBOLS"
# WEAK_SYMBOLS_BARRIER

# Add you new compiler version here
CLANG_VERSIONS="clang-3.0_3.0 clang-3.9_3.9 clang_7.1.0 clang_9.0.1 clang_11.0.1"
GCC_VERSIONS="gcc_5.4.0 gcc_6.2.0 gcc_7.2.0 gcc_8.3.0 gcc_10.2.0"
COMPILERS="${CLANG_VERSIONS} ${GCC_VERSIONS}"

# Add you new compiler options here
OPTIMIZATIONS="O0 O1 O2 O3"


# -------- Configure debug options
LOGDIR="./log"
TRACEDIR="/tmp/SMTDIR/trace/"

# Enables debug with 'y' and disable with 'n'
# DEBUG="y"
DEBUG="n"



# -------- Nothing left to configure down there :)
#
# Set the debug level of binsec
if [ ${DEBUG} = "y" ]; then
    rm -R "/tmp/SMTDIR/"
    mkdir -p "${TRACEDIR}"
    ADD_DEBUG=" -relse-debug-level 10 -relse-print-model -sse-address-trace-file ${TRACEDIR}"
else
    ADD_DEBUG=" -relse-debug-level 0"
fi

# [run binary_file] Run binsec on the specified [binary_file]
run() {
    NAME="${1}"

    LOGFILE="${LOGDIR}/${NAME}"
	mkdir -p ${LOGDIR}

    CMD="binsec relse -fml-solver-timeout 0 -relse-timeout 3600 \
    -sse-depth 0 -sse-memory memory.txt -relse-paths 0 -sse-load-ro-sections \
    -sse-load-sections .got.plt,.data,.plt,.bss -relse-stat-prefix ${NAME} \
    -fml-solver boolector -relse-store-type rel \
    -relse-memory-type row-map -relse-property secret-erasure -relse-dedup 1 \
    -relse-fp instr -relse-leak-info instr bin/${NAME} ${ADD_DEBUG}"

    echo "${CMD}" > "${LOGFILE}"
    eval "${CMD}" >> "${LOGFILE}" 2>&1
    RES=$?
    if [ ${RES} -eq 0 ]; then
        RESULT="SECURE"
    elif [ ${RES} -eq 7 ]; then
        RESULT="INSECURE"
    elif [ ${RES} -eq 8 ]; then
        RESULT="UNKNOWN"
    else
        RESULT="ERROR"
    fi
}

# [check binary_file result] Run binsec on the specified [binary_file] and check
#                            that the result matches [result]
check () {
    NAME="${1}"
    EXPECTED="${2}"
    run "${NAME}"
    if [ "${RESULT}" != "${EXPECTED}" ]; then
       echo "Program ${NAME} expected ${EXPECTED}, got ${RESULT}"
       exit 1
    else
        echo "$NAME: ${RESULT}, OK"
    fi
}


# Run unit tests
unit_tests() {
    # Checking validity (checked by hand)
    check "secret-erasure_LOOP_O0_gcc_10.2.0" "SECURE"
    check "secret-erasure_LOOP_O1_gcc_10.2.0" "SECURE"
    check "secret-erasure_LOOP_O2_gcc_10.2.0" "INSECURE"
    check "secret-erasure_LOOP_O3_gcc_10.2.0" "INSECURE"

    check "secret-erasure_MEMSET_O0_gcc_10.2.0" "SECURE"
    check "secret-erasure_MEMSET_O1_gcc_10.2.0" "SECURE"
    check "secret-erasure_MEMSET_O2_gcc_10.2.0" "INSECURE"
    check "secret-erasure_MEMSET_O3_gcc_10.2.0" "INSECURE"

    check "secret-erasure_MEMSET_S_O0_gcc_10.2.0" "SECURE"
    check "secret-erasure_MEMSET_S_O1_gcc_10.2.0" "SECURE"
    check "secret-erasure_MEMSET_S_O2_gcc_10.2.0" "SECURE"
    check "secret-erasure_MEMSET_S_O3_gcc_10.2.0" "SECURE"

    printf "\n Unit tests passed !\n\n"
}


# Generate latex tables
# read -ar clang_array <<< "${CLANG_VERSIONS}"
# (read -a ${CLANG_VERSIONS})
clang_array=(${CLANG_VERSIONS})
last_clang_compiler="${clang_array[-1]}"
gcc_array=(${GCC_VERSIONS})
last_gcc_compiler="${gcc_array[-1]}"
optimizations_array=(${OPTIMIZATIONS})
last_optimization="${optimizations_array[-1]}"

print_results_latex () {
    scrubbing_function="$1"
    compiler="$2"
    for optimization in ${OPTIMIZATIONS}
    do
        NAME="secret-erasure_${scrubbing_function}_${optimization}_${compiler}"
        run "${NAME}"
        if [ ${RESULT} = "SECURE" ]; then
            echo -n "\ccmark{}"
        elif [ ${RESULT} = "INSECURE" ]; then
            echo -n "\cxmark{}"
        elif [ ${RESULT} = "UNKNOWN" ]; then
            echo -n "\csmark{}"
        else
            echo -n "Error"
        fi
        if [ "${compiler}" = "${last_gcc_compiler}" ] ||
               [ "${compiler}" = "${last_clang_compiler}" ] &&
               [ "${optimization}" = "${last_optimization}" ]; then
            echo " \\\\"
        else
            echo -n " & "
        fi
    done
}

pp_function_name_to_latex () {
    pp_scrubbing_function="${1}"
    pp_scrubbing_function="${pp_scrubbing_function,,}"
    pp_scrubbing_function="${pp_scrubbing_function//_/\\_}"
    printf "\\\texttt{%s} & " "${pp_scrubbing_function}"
}

generate_latex_table () {
    # Results for clang
    echo "CLANG"
    for scrubbing_function in ${SCRUBBING_FUNCTIONS}
    do
        pp_function_name_to_latex "${scrubbing_function}"
        for compiler in ${CLANG_VERSIONS}
        do
            print_results_latex "${scrubbing_function}" "${compiler}"
        done
    done

    # Results for gcc
    echo "GCC"
    for scrubbing_function in ${SCRUBBING_FUNCTIONS}
    do
        pp_function_name_to_latex "${scrubbing_function}"
        for compiler in ${GCC_VERSIONS}
        do
            print_results_latex "${scrubbing_function}" "${compiler}"
        done
    done
}

# [pp_scrubbing_functions scrubbing_functions]
pp_scrubbing_functions () {
    for scrubbing_function in ${1}
    do
        for compiler in ${COMPILERS}
        do
            for optimization in ${OPTIMIZATIONS}
            do
                NAME="secret-erasure_${scrubbing_function}_${optimization}_${compiler}"
                run "${NAME}"
                echo "$NAME: ${RESULT}"
            done
        done
    done
}

# [pp_compilers compilers]
pp_compilers () {
    for compiler in ${1}
    do
        for scrubbing_function in ${SCRUBBING_FUNCTIONS}
        do
            for optimization in ${OPTIMIZATIONS}
            do
                NAME="secret-erasure_${scrubbing_function}_${optimization}_${compiler}"
                run "${NAME}"
                echo "$NAME: ${RESULT}"
            done
        done
    done
}


wrong_usage() {
    echo "Usage: analyze.sh [ test | latex | all | compiler <compiler_name> | function <scrub macro> ]"
    exit 1
}

if [ "${1}" = "test" ]; then
    unit_tests
elif [ "${1}" = "latex" ]; then
    generate_latex_table
elif [ "${1}" = "all" ]; then
    pp_scrubbing_functions "${SCRUBBING_FUNCTIONS}"
elif [ "${1}" = "compiler" ]; then
    if [ "${2}" = "" ]; then wrong_usage; else pp_compilers "${2}"; fi
elif [ "${1}" = "function" ]; then
    if [ "${2}" = "" ]; then wrong_usage; else pp_scrubbing_functions "${2}"; fi
else
    wrong_usage
fi

exit 0
