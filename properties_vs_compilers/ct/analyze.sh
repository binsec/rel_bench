#!/usr/bin/bash
#
# Run binsec on a set of binary files and check whether they enforce
# secret-erasure or if they fail to scrub secret-data from memory.
#
# All results can be found in the `log` subdirectory. By default, if results are
# found in `log`, they are not recomputed. Delete files in `log` to rerun binsec
# and recompute the results.
##
LOGDIR="./log"
BINSEC_PATH=binsec-rel

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
CLANG_VERSIONS_x86="clang-3.0_3.0 clang-3.9_3.9 clang_7.1.0 clang_9.0.1 clang_11.0.1"
GCC_VERSIONS_x86="gcc_5.4.0 gcc_6.2.0 gcc_7.2.0 gcc_8.3.0 gcc_10.2.0"
ALL_COMPILERS_x86="${CLANG_VERSIONS_x86} ${GCC_VERSIONS_x86}"
GCC_VERSIONS_ARM="arm-linux-gnueabi-gcc_10.3"

# Add you new compiler options here
OPTIMIZATIONS="O0 O1 O2 O3"
OPTIMIZATIONS_CLANG="${OPTIMIZATIONS} O3-cmov"
OPTIMIZATIONS_GCC="O0 O0-cmov O1 O2 O3 O3-cmov"
ARCH="i386 i686"

# -------- Configure debug options
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

for dir in ct-select ct-sort hacl_utility openssl_utility tea; do
    mkdir -p ${PWD}/log/${dir}
done

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

    if ! [ -f "${LOGFILE}" ]; then
        echo "${CMD}" > "${LOGFILE}"
        eval "${CMD}" >> "${LOGFILE}" 2>&1
    fi

    if grep "Result:	Secure" "${LOGFILE}" >> /dev/null; then
        RESULT="SECURE"
    elif grep "Result:	Insecure" "${LOGFILE}"  >> /dev/null; then
        RESULT=""
        if grep "\[relse:result\] \[Insecurity\]\[Violation\] Insecure memory access" "${LOGFILE}" >> /dev/null; then
            RESULT="MEM"
        elif grep "\[relse:result\] \[Insecurity\]\[Violation\] Insecure jump" "${LOGFILE}" >> /dev/null; then
             RESULT="${RESULT}CF"
        fi
    elif grep "Result:  Unknown" "${LOGFILE}" >> /dev/null; then
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
    check "./ct-select/ct_select_v1_O3_clang_7.1.0" "CF"
    check "./ct-select/ct_select_v1_O3-cmov_clang_7.1.0" "CF"

    check "./ct-sort/sort_O0_gcc_8.3.0" "CF"
    check "./ct-sort/sort_O3_gcc_8.3.0" "SECURE"
    check "./ct-sort/sort_O0-cmov_gcc_8.3.0" "CF"
    check "./ct-sort/sort_O3-cmov_gcc_8.3.0" "SECURE"
    check "./ct-sort/sort_O0_clang_7.1.0" "SECURE"
    check "./ct-sort/sort_O3_clang_7.1.0" "SECURE"
    check "./ct-sort/sort_O3-cmov_clang_7.1.0" "SECURE"

    check "./ct-select/naive_select_O3-cmov_clang_7.1.0" "CF"
    check "./ct-select/naive_select_O3-cmov_gcc_8.3.0" "CF"
    check "./ct-select/naive_select_O0_arm-linux-gnueabi-gcc_10.3" "CF"
    check "./ct-select/naive_select_O0-cmov_arm-linux-gnueabi-gcc_10.3" "CF"
    check "./ct-select/naive_select_O3_arm-linux-gnueabi-gcc_10.3" "SECURE"
    check "./ct-select/naive_select_O3-cmov_arm-linux-gnueabi-gcc_10.3" "CF"

    printf "\n Unit tests passed !\n\n"
}

print_results_latex () {
    programs="$1"
    compiler="$2"
    optimization="$3"
    NAME="${program}_${optimization}_${compiler}"
    run "${NAME}"
    if [ ${RESULT} = "SECURE" ]; then
        echo -n "\ccmark{}"
    elif [ ${RESULT} = "CF" ]; then
        echo -n "\textsc{\textcolor{red}{c}}"
    elif [ ${RESULT} = "MEM" ]; then
        echo -n "\textsc{\textcolor{red}{m}}"
    elif [ ${RESULT} = "MEMCF" ]; then
        echo -n "\textsc{\textcolor{red}{b}}"
    elif [ ${RESULT} = "UNKNOWN" ]; then
        echo -n "\csmark{}"
    else
        echo -n "-"
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
                if [ "${4}" != "" ]; then
                    option="${option}-${4}"
                fi
                print_results_latex "${program}" "${compiler}" "${option}"
            done
        done
        echo "\\\\"
    done
}

# Generate final clang table for the paper
generate_latex_table_clang () {
    for program in ${1}
    do
        first="t"
        pp_program_name_to_latex "${program}"
        for compiler in clang-3.0_3.0 clang-3.9_3.9
        do
            for option in ${OPTIMIZATIONS_CLANG}
            do
                if [ "${first}" = "t" ]; then
                    first="f"
                else
                    echo -n " & "
                fi
                print_results_latex "${program}" "${compiler}" "${option}-i686"
            done
        done
        for compiler in clang_7.1.0 clang_9.0.1
        do
            for arch in i386 i686; do
                for option in ${OPTIMIZATIONS_CLANG}
                do
                    if [ "${first}" = "t" ]; then
                        first="f"
                    else
                        echo -n " & "
                    fi
                    print_results_latex "${program}" "${compiler}" "${option}-${arch}"
                done
            done
        done
        echo "\\\\"
    done
}

# Final gcc table for the paper
generate_latex_table_gcc () {
    for program in ${1}
    do
        first="t"
        pp_program_name_to_latex "${program}"
        for compiler in "gcc_10.2.0"
        do
            for arch in i386 i686; do
                for option in ${OPTIMIZATIONS_GCC}
                do
                    if [ "${first}" = "t" ]; then
                        first="f"
                    else
                        echo -n " & "
                    fi
                    print_results_latex "${program}" "${compiler}" "${option}-${arch}"
                done
            done
        done
        for compiler in "arm-linux-gnueabi-gcc_10.3"
        do
            for option in ${OPTIMIZATIONS_GCC}
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

# Ugly ad-hoc function to generate final table for the paper
generate_latex_table_clang_gcc () {
    programs="${ct_select_all} ${ct_sort_all} ${openssl_utility_all%% *} ${hacl_utility_all%% *} ${tea_all%% *}"
    for program in  ${programs}
    do
        first="t"
        pp_program_name_to_latex "${program}"
        for compiler in clang-3.0_3.0 clang-3.9_3.9
        do
            for option in ${OPTIMIZATIONS_CLANG}
            do
                if [ "${first}" = "t" ]; then
                    first="f"
                else
                    echo -n " & "
                fi
                print_results_latex "${program}" "${compiler}" "${option}-i686"
            done
        done
        for compiler in clang_7.1.0 clang_9.0.1
        do
            for arch in i386 i686; do
                for option in ${OPTIMIZATIONS_CLANG}
                do
                    if [ "${first}" = "t" ]; then
                        first="f"
                    else
                        echo -n " & "
                    fi
                    print_results_latex "${program}" "${compiler}" "${option}-${arch}"
                done
            done
        done
        for compiler in "gcc_10.2.0"
        do
            for arch in i386 i686; do
                for option in ${OPTIMIZATIONS_GCC}
                do
                    if [ "${first}" = "t" ]; then
                        first="f"
                    else
                        echo -n " & "
                    fi
                    print_results_latex "${program}" "${compiler}" "${option}-${arch}"
                done
            done
        done
        for compiler in "arm-linux-gnueabi-gcc_10.3"
        do
            for option in ${OPTIMIZATIONS_GCC}
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
            for option in ${3}
            do
                if [ "${4}" != "" ]; then
                    option="${option}-${4}"
                fi
                NAME="${program}_${option}_${compiler}"
                run "${NAME}"
                echo "$NAME: ${RESULT}"
            done
        done
    done
}

wrong_usage() {
    echo "Usage: analyze.sh [ test | latex <output_dir> | all | compiler <compiler_name> | program <program_path> ]"
    exit 1
}

if [ "${1}" = "test" ]; then
    unit_tests
elif [ "${1}" = "latex" ]; then
    if [ "${2}" = "" ]; then
        wrong_usage;
    else
        # echo "% -- CLANG-i386" > ${2}/clang-i386.tex
        # generate_latex_table "${ALL_PROGRAMS}" "${CLANG_VERSIONS_x86}" "${OPTIMIZATIONS_CLANG}" "i386"  >> ${2}/clang-i386.tex
        # echo "% -- GCC-i386" > ${2}/gcc-i386.tex
        # generate_latex_table "${ALL_PROGRAMS}" "${GCC_VERSIONS_x86}" "${OPTIMIZATIONS_GCC}" "i386" >> ${2}/gcc-i386.tex
        # echo "% -- CLANG-i686" > ${2}/clang-i686.tex
        # generate_latex_table "${ALL_PROGRAMS}" "${CLANG_VERSIONS_x86}" "${OPTIMIZATIONS_CLANG}" "i686" >> ${2}/clang-i686.tex
        # echo "% -- GCC-i686" > ${2}/gcc-i686.tex
        # generate_latex_table "${ALL_PROGRAMS}" "${GCC_VERSIONS_x86}" "${OPTIMIZATIONS_GCC}" "i686" >> ${2}/gcc-i686.tex
        # echo "% -- GCC-arm" > ${2}/gcc-arm.tex
        # generate_latex_table "${ALL_PROGRAMS}" "${GCC_VERSIONS_ARM}" "${OPTIMIZATIONS_GCC}" "" >> ${2}/gcc-arm.tex
        # echo "% -- CLANG" > ${2}/clang.tex
        # generate_latex_table_clang "${ALL_PROGRAMS}" >> ${2}/clang.tex
        # echo "% -- GCC" > ${2}/gcc.tex
        # generate_latex_table_gcc "${ALL_PROGRAMS}" >> ${2}/gcc.tex
        echo "% -- CLANG-GCC" > ${2}/clang-gcc.tex
        generate_latex_table_clang_gcc >> ${2}/clang-gcc.tex
    fi
elif [ "${1}" = "all" ]; then
    pp_results "${ALL_PROGRAMS}" "${CLANG_VERSIONS_x86}" "${OPTIMIZATIONS_CLANG}" "i386"
    pp_results "${ALL_PROGRAMS}" "${GCC_VERSIONS_x86}" "${OPTIMIZATIONS_GCC}" "i386"
    pp_results "${ALL_PROGRAMS}" "${CLANG_VERSIONS_x86}" "${OPTIMIZATIONS_CLANG}" "i686"
    pp_results "${ALL_PROGRAMS}" "${GCC_VERSIONS_x86}" "${OPTIMIZATIONS_GCC}" "i686"
    pp_results "${ALL_PROGRAMS}" "${GCC_VERSIONS_ARM}" "${OPTIMIZATIONS_GCC}" ""
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
