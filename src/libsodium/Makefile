CFLAGS=-Wall -m32 -g -fno-stack-protector -static -O0
export WD          ?= ${PWD}
export CPATH       += ${PWD}/libsodium/src/libsodium/include:${PWD}/libsodium/src/libsodium/include/sodium
LIBSYM=-L../../__libsym__/ -lsym

LIBDIR             = libsodium/src/libsodium

.PHONY: all clean chacha20 salsa20 sha256 sha512

all: chacha20 salsa20 sha256 sha512

# CHACHA20
CHACHA20_LIBS = sodium/utils.c																				\
                     randombytes/sysrandom/randombytes_sysrandom.c		\
                     randombytes/randombytes.c												\
                     crypto_stream/chacha20/ref/stream_chacha20_ref.c	\
                     crypto_stream/chacha20/stream_chacha20_api.c

chacha20:
	 gcc $(CFLAGS) $(patsubst %,$(LIBDIR)/%,$(CHACHA20_LIBS)) $@_wrapper.c -o $@ $(LIBSYM)


# SALSA20
SALSA20_LIBS = sodium/utils.c																			 \
                    randombytes/sysrandom/randombytes_sysrandom.c	 \
                    randombytes/randombytes.c											 \
                    crypto_core/salsa20/ref/core_salsa20.c         \
										crypto_stream/salsa20/stream_salsa20_api.c     \
										crypto_stream/salsa20/ref/xor_salsa20_ref.c

salsa20:
	 gcc $(CFLAGS) $(patsubst %,$(LIBDIR)/%,$(SALSA20_LIBS)) $@_wrapper.c -o $@ $(LIBSYM)


# SHA256
SHA256_LIBS = sodium/utils.c																			\
                   randombytes/sysrandom/randombytes_sysrandom.c	\
                   randombytes/randombytes.c											\
                   crypto_hash/sha256/cp/hash_sha256.c

sha256:
	 gcc $(CFLAGS) $(patsubst %,$(LIBDIR)/%,$(SHA256_LIBS)) $@_wrapper.c -o $@ $(LIBSYM)


# SHA512
SHA512_LIBS = sodium/utils.c																			\
                   randombytes/sysrandom/randombytes_sysrandom.c	\
                   randombytes/randombytes.c											\
                   crypto_hash/sha512/cp/hash_sha512.c

sha512:
	 gcc $(CFLAGS) $(patsubst %,$(LIBDIR)/%,$(SHA512_LIBS)) $@_wrapper.c -o $@ $(LIBSYM)

# # AUTH
# AUTH_LIBS      = sodium/utils.c \
#                  randombytes/randombytes.c randombytes/sysrandom/randombytes_sysrandom.c \
#                  crypto_hash/sha256/cp/hash_sha256.c crypto_auth/hmacsha256/cp/hmac_hmacsha256.c

# auth_pub:
# 	@make auth_pub-verify

# auth_pub-%:
# 	 gcc $(CFLAGS)  $(patsubst %,$(LIBDIR)/%,$(_LIBS))  .c -o 

# auth_prv:
# 	@make auth_prv-verify

# auth_prv-%:
# 	 gcc $(CFLAGS)  $(patsubst %,$(LIBDIR)/%,$(_LIBS))  .c -o 


# # POLY1305
# POLY1305_LIBS      = sodium/utils.c \
#                      randombytes/sysrandom/randombytes_sysrandom.c randombytes/randombytes.c \
#                      crypto_verify/16/ref/verify_16.c \
#                      crypto_onetimeauth/poly1305/donna/auth_poly1305_donna.c \
#                      crypto_onetimeauth/poly1305/donna/verify_poly1305_donna.c

# poly1305:
# 	@make poly1305-verify

# poly1305-%:
# 	 gcc $(CFLAGS)  $(patsubst %,$(LIBDIR)/%,$(_LIBS))  .c -o 


# # AEAD (CHACHA20 + POLY1305)
# AEAD_LIBS = sodium/utils.c \
#             randombytes/randombytes.c randombytes/sysrandom/randombytes_sysrandom.c \
#             crypto_stream/chacha20/ref/stream_chacha20_ref.c crypto_stream/chacha20/stream_chacha20_api.c \
#             crypto_onetimeauth/crypto_onetimeauth.c crypto_onetimeauth/poly1305/onetimeauth_poly1305.c \
#             crypto_onetimeauth/poly1305/donna/auth_poly1305_donna.c crypto_onetimeauth/poly1305/donna/verify_poly1305_donna.c \
#             crypto_verify/16/ref/verify_16.c \
#             crypto_aead/chacha20poly1305/sodium/aead_chacha20poly1305.c

# aead:
# 	@make aead-verify

# aead-%:
# 	 gcc $(CFLAGS)  $(patsubst %,$(LIBDIR)/%,$(_LIBS))  .c -o 


clean:
	rm -rf *.o *.csv *.out smtdir/*/*.smt2
	rmdir smtdir/binsec_relse smtdir/binsec_sse
