#!/usr/bin/bash
#
# Run binsec on a set of binary files and check whether they enforce
# secret-erasure or if they fail to scrub secret-data from memory.

BINSEC_PATH=binsec_rel

# -------- Configure which binary files to analyze
#
# Add you new scrubbing function here
ct_select_all="ct_select_v1 ct_select_v2 ct_select_v3 ct_select_v4 naive_select"
ct_select_all=$(echo "$ct_select_all" | sed 's/[^ ]* */ct-select\/&/g')
ct_sort_all="sort sort_multiplex sort_negative"
ct_sort_all=$(echo "$ct_sort_all" | sed 's/[^ ]* */ct-sort\/&/g')
tea_all="tea_encrypt tea_decrypt"
tea_all=$(echo "$tea_all" | sed 's/[^ ]* */tea\/&/g')
openssl_utility_all="ct_eq_8 ct_eq_int ct_is_zero_8 ct_lt ct_select ct_eq ct_ge_8 ct_is_zero ct_msb ct_eq_int_8 ct_ge ct_lt_8 ct_select_8"
openssl_utility_all=$(echo "$openssl_utility_all" | sed 's/[^ ]* */openssl_utility\/&/g')
hacl_utility_all="cmp_bytes rotate32_left rotate32_right uint8_eq_mask uint8_gte_mask uint16_eq_mask uint16_gte_mask uint32_eq_mask uint32_gte_mask uint64_eq_mask uint64_gte_mask"
hacl_utility_all=$(echo "$hacl_utility_all" | sed 's/[^ ]* */hacl_utility\/&/g')
ALL_PROGRAMS="${ct_select_all} ${ct_sort_all} ${openssl_utility_all} ${hacl_utility_all} ${tea_all}"

# Add you new compiler version here
CLANG_VERSIONS="clang-3.0_3.0 clang-3.9_3.9 clang_7.1.0 clang_9.0.1 clang_11.0.1"
GCC_VERSIONS="gcc_5.4.0 gcc_6.2.0 gcc_7.2.0 gcc_8.3.0 gcc_10.2.0 arm-linux-gnueabi-gcc_10.3"
ALL_COMPILERS="${CLANG_VERSIONS} ${GCC_VERSIONS}"

# Add you new compiler options here
OPTIMIZATIONS="O0 O1 O2 O3"
OPTIMIZATIONS_CLANG="${OPTIMIZATIONS} O3-cmov"
OPTIMIZATIONS_GCC="O0 O0-cmov O1 O2 O3 O3-cmov"

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

    CMD="${BINSEC_PATH} relse -fml-solver-timeout 0 -relse-timeout 3600 \
    -sse-depth 0 -sse-memory memory.txt -relse-paths 0 -sse-load-ro-sections \
    -sse-load-sections .got.plt,.data,.plt,.bss -relse-stat-prefix ${NAME} \
    -fml-solver boolector -relse-store-type rel \
    -relse-memory-type row-map -relse-property ct -relse-dedup 1 \
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
    check "./tea/tea_encrypt_O0_gcc_8.3.0" "SECURE"
    check "./tea/tea_encrypt_O3_gcc_8.3.0" "SECURE"
    check "./tea/tea_encrypt_O0-cmov_gcc_8.3.0" "SECURE"
    check "./tea/tea_encrypt_O0_clang_7.1.0" "SECURE"
    check "./tea/tea_encrypt_O3_clang_7.1.0" "SECURE"
    check "./tea/tea_encrypt_O3-cmov_clang_7.1.0" "SECURE"

    check "./ct-select/ct_select_v1_O0_gcc_8.3.0" "SECURE"
    check "./ct-select/ct_select_v1_O3_gcc_8.3.0" "SECURE"
    check "./ct-select/ct_select_v1_O0-cmov_gcc_8.3.0" "SECURE"
    check "./ct-select/ct_select_v1_O0_clang_7.1.0" "SECURE"
    check "./ct-select/ct_select_v1_O3_clang_7.1.0" "INSECURE"
    check "./ct-select/ct_select_v1_O3-cmov_clang_7.1.0" "INSECURE"

    check "./ct-sort/sort_O0_gcc_8.3.0" "INSECURE"
    check "./ct-sort/sort_O3_gcc_8.3.0" "INSECURE"
    check "./ct-sort/sort_O0-cmov_gcc_8.3.0" "INSECURE"
    check "./ct-sort/sort_O0_clang_7.1.0" "INSECURE"
    check "./ct-sort/sort_O3_clang_7.1.0" "SECURE"
    check "./ct-sort/sort_O3-cmov_clang_7.1.0" "SECURE"

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
    programs="$1"
    compiler="$2"
    optimization="$3"
    NAME="${program}_${optimization}_${compiler}"
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

pp_program_name_to_latex () {
    program_name="${1}"
    program_name=$(echo "$program_name" | sed -e "s/^.*\///")
    program_name="${program_name//_/\\_}"
    printf "\\\texttt{%s} & " "${program_name}"
}

generate_latex_table () {
    for program in ${1}
    do
        first="t"
        pp_program_name_to_latex "${program}"
        for compiler in ${2}
        do
            for option in ${3}
            do
                if [ "${first}" = "t" ]; then
                    first="f"
                else
                    echo -n " & "
                fi
                print_results_latex "${program}" "${compiler}" "${option}"
            done
        done
        echo "\\\\"
    done
}

# [pp_results scrubbing_functions compilers optimization]
pp_results () {
    for program in ${1}
    do
        for compiler in ${2}
        do
            for optimization in ${3}
            do
                NAME="${program}_${optimization}_${compiler}"
                run "${NAME}"
                echo "$NAME: ${RESULT}"
            done
        done
    done
}

wrong_usage() {
    echo "Usage: analyze.sh [ test | latex | all | compiler <compiler_name> | program <program_path> ]"
    exit 1
}

if [ "${1}" = "test" ]; then
    unit_tests
elif [ "${1}" = "latex" ]; then
    echo "CLANG"
    generate_latex_table "${ALL_PROGRAMS}" "${CLANG_VERSIONS}" "${OPTIMIZATIONS_CLANG}"
    echo "GCC"
    generate_latex_table "${ALL_PROGRAMS}" "${GCC_VERSIONS}" "${OPTIMIZATIONS_GCC}"
elif [ "${1}" = "all" ]; then
    pp_results "${ALL_PROGRAMS}" "${CLANG_VERSIONS}" "${OPTIMIZATIONS_CLANG}"
    pp_results "${ALL_PROGRAMS}" "${GCC_VERSIONS}" "${OPTIMIZATIONS_GCC}"
elif [ "${1}" = "compiler" ]; then
    if [ "${2}" = "" ]; then
        wrong_usage;
    else
        if [[ "${2}" =~ "^clang*" ]]; then
            pp_results "${ALL_PROGRAMS}" "${2}" "${OPTIMIZATIONS_CLANG}"
        else
            pp_results "${ALL_PROGRAMS}" "${2}" "${OPTIMIZATIONS_GCC}"
        fi
    fi
elif [ "${1}" = "function" ]; then
    if [ "${2}" = "" ]; then wrong_usage; else
        pp_results "${2}" "${CLANG_VERSIONS}" "${OPTIMIZATIONS_CLANG}"
        pp_results "${2}" "${GCC_VERSIONS}" "${OPTIMIZATIONS_GCC}"
    fi
else
    wrong_usage
fi

exit 0
