#!/usr/bin/bash
#
# Run binsec on a set of binary files and check whether they enforce
# secret-erasure or if they fail to scrub secret-data from memory.

BINSEC_PATH=binsec_rel

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
ALL_COMPILERS="${CLANG_VERSIONS} ${GCC_VERSIONS}"

# Add you new compiler options here
OPTIMIZATIONS="O0 O1 O2 O3"
NO_DSE_OPTIONS_CLANG="witnessO3 no-dse"
NO_DSE_OPTIONS_GCC="witnessO3 no-dse no-tree-dse no-dse-all"

# -------- Configure debug options
LOGDIR="./log-dummy"
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

    CMD="${BINSEC_PATH} relse -fml-solver-timeout 0 -relse-timeout 3600 \
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
    optimization="$3"
    NAME="secret-erasure_${scrubbing_function}_${optimization}_${compiler}"
    run "${NAME}"
    if [ ${RESULT} = "SECURE" ]; then
        echo -n "\ccmark{}"
    elif [ ${RESULT} = "INSECURE" ]; then
        echo -n "\cxmark{}"
    elif [ ${RESULT} = "UNKNOWN" ]; then
        echo -n "\csmark{}"
    else
        echo -n "\textsc{na}"
    fi
}

pp_function_name_to_latex () {
    pp_scrubbing_function="${1}"
    pp_scrubbing_function="${pp_scrubbing_function,,}"
    pp_scrubbing_function="${pp_scrubbing_function//_/\\_}"
    printf "\\\texttt{%s} & " "${pp_scrubbing_function}"
}

generate_latex_table () {
    for scrubbing_function in ${1}
    do
        first="t"
        pp_function_name_to_latex "${scrubbing_function}"
        for compiler in ${2}
        do
            for option in ${3}
            do
                if [ "${first}" = "t" ]; then
                    first="f"
                else
                    echo -n " & "
                fi
                print_results_latex "${scrubbing_function}" "${compiler}" "${option}"
            done
        done
        echo "\\\\"
    done
}

# [pp_results scrubbing_functions compilers optimization]
pp_results () {
    for scrubbing_function in ${1}
    do
        for compiler in ${2}
        do
            for optimization in ${3}
            do
                NAME="secret-erasure_${scrubbing_function}_${optimization}_${compiler}"
                run "${NAME}"
                echo "$NAME: ${RESULT}"
            done
        done
    done
}

wrong_usage() {
    echo "Usage: analyze.sh [ test | latex-opt | latex-no-dse | all-opt | all-no-dse | compiler <compiler_name> | function <scrub macro> ]"
    exit 1
}

if [ "${1}" = "test" ]; then
    unit_tests
elif [ "${1}" = "latex-opt" ]; then
    echo "CLANG"
    generate_latex_table "${SCRUBBING_FUNCTIONS}" "${CLANG_VERSIONS}" "${OPTIMIZATIONS}"
    echo "GCC"
    generate_latex_table "${SCRUBBING_FUNCTIONS}" "${GCC_VERSIONS}" "${OPTIMIZATIONS}"
elif [ "${1}" = "latex-no-dse" ]; then
    echo "CLANG"
    generate_latex_table "${SCRUBBING_FUNCTIONS}" "${CLANG_VERSIONS}" "${NO_DSE_OPTIONS_CLANG}"
    echo "GCC"
    generate_latex_table "${SCRUBBING_FUNCTIONS}" "${GCC_VERSIONS}" "${NO_DSE_OPTIONS_GCC}"
elif [ "${1}" = "all-opt" ]; then
    pp_results "${SCRUBBING_FUNCTIONS}" "${ALL_COMPILERS}" "${OPTIMIZATIONS}"
elif [ "${1}" = "all-no-dse" ]; then
    pp_results "${SCRUBBING_FUNCTIONS}" "${CLANG_VERSIONS}" "${NO_DSE_OPTIONS_CLANG}"
    pp_results "${SCRUBBING_FUNCTIONS}" "${GCC_VERSIONS}" "${NO_DSE_OPTIONS_GCC}"
elif [ "${1}" = "compiler" ]; then
    if [ "${2}" = "" ]; then
        wrong_usage;
    else
        pp_results "${SCRUBBING_FUNCTIONS}" "${2}" "${OPTIMIZATIONS}"
        if [[ "${2}" =~ "^clang*" ]]; then
            pp_results "${SCRUBBING_FUNCTIONS}" "${2}" "${NO_DSE_OPTIONS_CLANG}"
        else
            pp_results "${SCRUBBING_FUNCTIONS}" "${2}" "${NO_DSE_OPTIONS_GCC}"
        fi
    fi
elif [ "${1}" = "function" ]; then
    if [ "${2}" = "" ]; then wrong_usage; else
        pp_results "${2}" "${ALL_COMPILERS}" "${OPTIMIZATIONS}"
        pp_results "${2}" "${CLANG_VERSIONS}" "${NO_DSE_OPTIONS_CLANG}"
        pp_results "${2}" "${GCC_VERSIONS}" "${NO_DSE_OPTIONS_GCC}"
    fi
else
    wrong_usage
fi

exit 0
