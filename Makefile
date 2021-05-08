# Target
OUT_DIR="./__results__"
# OUT_DIR="./__tests__"

# ==== RULES ====
.PHONY: all t tests donna_scale ct_select ct_sort tea donna hacl bearssl toys libsodium test secret_erasure

all: tests

# Run default test in run.py
unit_test:
	./run.py -t

# Unit tests, check that everything works fine
tests:
	./run.py -d toys -e test -o /tmp/$@ -n 1 -fp instr -dd 2 -depth 0 -store -store bin-rel

##########################################
# Best options
##########################################
ARGS_BEST=-e best
# Utility - ct-select
ct_select:
	./run.py -d ct-select -o ${OUT_DIR}/$@ ${ARGS_BEST}

# Utility - ct-sort
ct_sort:
	./run.py -d ct-sort -o ${OUT_DIR}/$@ ${ARGS_BEST}

# Utility - HACL*
utility_hacl:
	./run.py -d hacl_utility -o ${OUT_DIR}/$@ ${ARGS_BEST}

# Utility - OpenSSL
utility_openssl:
	./run.py -d openssl_utility -o ${OUT_DIR}/$@ ${ARGS_BEST}

# Tea
tea:
	./run.py -d tea_0 -o ${OUT_DIR}/$@ ${ARGS_BEST}
	./run.py -d tea_3 -o ${OUT_DIR}/$@ ${ARGS_BEST}

# Donna
donna:
	./run.py -d donna_0 -o ${OUT_DIR}/$@ ${ARGS_BEST}
	./run.py -d donna_3 -o ${OUT_DIR}/$@ ${ARGS_BEST}

# libsodium
nacl_chacha20:
	./run.py -d nacl_chacha20 -o ${OUT_DIR}/$@ ${ARGS_BEST}
nacl_salsa20:
	./run.py -d nacl_salsa20 -o ${OUT_DIR}/$@ ${ARGS_BEST}
nacl_sha256:
	./run.py -d nacl_sha256 -o ${OUT_DIR}/$@ ${ARGS_BEST}
nacl_sha512:
	./run.py -d nacl_sha512 -o ${OUT_DIR}/$@ ${ARGS_BEST}

# Hacl*
hacl_chacha20:
	./run.py -d hacl_chacha20 -o ${OUT_DIR}/$@ ${ARGS_BEST}
hacl_curve25519:
	./run.py -d hacl_curve25519 -o ${OUT_DIR}/$@ ${ARGS_BEST}
hacl_sha256:
	./run.py -d hacl_sha256 -o ${OUT_DIR}/$@ ${ARGS_BEST}
hacl_sha512:
	./run.py -d hacl_sha512 -o ${OUT_DIR}/$@ ${ARGS_BEST}
hacl: hacl_chacha20 hacl_curve25519 hacl_sha256 hacl_sha512

# BearSSL
des_tab:
	./run.py -d des_tab -o ${OUT_DIR}/$@ ${ARGS_BEST}
des_ct:
	./run.py -d des_ct -o ${OUT_DIR}/$@ ${ARGS_BEST}
aes_big:
	./run.py -d aes_big -o ${OUT_DIR}/$@ ${ARGS_BEST}
aes_ct:
	./run.py -d aes_ct -o ${OUT_DIR}/$@ ${ARGS_BEST}
bearssl: des_tab des_ct aes_big aes_ct

# openssl-almeida
openssl_almeida:
	./run.py -d openssl_almeida -o ${OUT_DIR}/$@ ${ARGS_BEST}

# Lucky 13 > Run "insecure" experiments to get verbose counterexamples
lucky13_verbose:
	./run.py -d tls1_cbc_remove_padding_lucky13 -e insecure -n 1 -to 3600 > ${OUT_DIR}/insecure/$@

# Secret erasure
secret-erasure:
	./run.py -d secret-erasure  ${ARGS_BEST} -o ${OUT_DIR}/$@ -prop secret-erasure


##########################################
# Scale experiments
##########################################
scale: scale_ct_select scale_ct_sort scale_utility_hacl scale_utility_openssl	\
	   scale_tea scale_donna scale_nacl_chacha20 scale_nacl_salsa20				\
	   scale_nacl_sha256 scale_nacl_sha512 scale_hacl_chacha20					\
	   scale_hacl_curve25519 scale_hacl_sha256 scale_hacl_sha512 scale_des_tab	\
	   scale_des_ct scale_aes_big scale_aes_ct scale_openssl_almeida

# Utility - ct-select
scale_ct_select:
	./run.py -d ct-select -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d ct-select -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d ct-select -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out

# Utility - ct-sort
scale_ct_sort:
	./run.py -d ct-sort -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d ct-sort -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d ct-sort -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out

# Utility - HACL*
scale_utility_hacl:
	./run.py -d hacl_utility -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_utility -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_utility -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out

# Utility - OpenSSL
scale_utility_openssl:
	./run.py -d openssl_utility -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d openssl_utility -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d openssl_utility -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out

# Tea
scale_tea:
	./run.py -d tea_0 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d tea_3 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d tea_0 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d tea_3 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d tea_0 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d tea_3 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out

# Donna
scale_donna:
	./run.py -d donna_0 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d donna_3 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d donna_0 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d donna_3 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d donna_0 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d donna_3 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out

# libsodium
scale_nacl_chacha20:
	./run.py -d nacl_chacha20 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d nacl_chacha20 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d nacl_chacha20 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_nacl_salsa20:
	./run.py -d nacl_salsa20 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d nacl_salsa20 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d nacl_salsa20 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_nacl_sha256:
	./run.py -d nacl_sha256 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d nacl_sha256 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d nacl_sha256 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_nacl_sha512:
	./run.py -d nacl_sha512 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d nacl_sha512 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d nacl_sha512 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out

# Hacl*
scale_hacl_chacha20:
	./run.py -d hacl_chacha20 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_chacha20 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_chacha20 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_hacl_curve25519:
	./run.py -d hacl_curve25519 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_curve25519 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_curve25519 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_hacl_sha256:
	./run.py -d hacl_sha256 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_sha256 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_sha256 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_hacl_sha512:
	./run.py -d hacl_sha512 -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_sha512 -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d hacl_sha512 -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out


# BearSSL
scale_des_tab:
	./run.py -d des_tab -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d des_tab -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d des_tab -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_des_ct:
	./run.py -d des_ct -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d des_ct -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d des_ct -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_aes_big:
	./run.py -d aes_big -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d aes_big -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d aes_big -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_aes_ct:
	./run.py -d aes_ct -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d aes_ct -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d aes_ct -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
scale_bearssl: scale_des_tab scale_des_ct scale_aes_big scale_aes_ct

#	Openssl-almeida
scale_openssl_almeida:
	./run.py -d openssl_almeida -e scale_std -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d openssl_almeida -e scale_brelse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
	./run.py -d openssl_almeida -e scale_sse -o ${OUT_DIR}/$@ -n 1 &>> ${OUT_DIR}/$@.out
