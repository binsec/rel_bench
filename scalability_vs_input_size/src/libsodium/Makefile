CFLAGS=-Wall -m32 -g -fno-stack-protector -static -O3 -fno-pie -fno-pic
export WD          ?= ${PWD}
export CPATH       += ${PWD}/libsodium/src/libsodium/include:${PWD}/libsodium/src/libsodium/include/sodium
LIBSYM=-L../../../__libsym__/ -lsym

LIBDIR             = libsodium/src/libsodium

.PHONY: all clean chacha20 salsa20 sha256 sha512

all: chacha20 salsa20 sha256 sha512

# CHACHA20
CHACHA20_LIBS = sodium/utils.c																				\
                     randombytes/sysrandom/randombytes_sysrandom.c		\
                     randombytes/randombytes.c												\
                     crypto_stream/chacha20/ref/stream_chacha20_ref.c	\
                     crypto_stream/chacha20/stream_chacha20_api.c

define compile_chacha20
	gcc $(CFLAGS) $(patsubst %,$(LIBDIR)/%,$(CHACHA20_LIBS)) $(1)_wrapper.c -o $(1)_$(2) $(LIBSYM) -D MSG_LEN=$(2)
endef

chacha20:
	@$(call compile_chacha20,chacha20,500)
	@$(call compile_chacha20,chacha20,1000)
	@$(call compile_chacha20,chacha20,1500)
	@$(call compile_chacha20,chacha20,2000)
	@$(call compile_chacha20,chacha20,2500)
	@$(call compile_chacha20,chacha20,3000)


# SALSA20
SALSA20_LIBS = sodium/utils.c																			 \
                    randombytes/sysrandom/randombytes_sysrandom.c	 \
                    randombytes/randombytes.c											 \
                    crypto_core/salsa20/ref/core_salsa20.c         \
										crypto_stream/salsa20/stream_salsa20_api.c     \
										crypto_stream/salsa20/ref/xor_salsa20_ref.c

define compile_salsa20
	gcc $(CFLAGS) $(patsubst %,$(LIBDIR)/%,$(SALSA20_LIBS)) $(1)_wrapper.c -o $(1)_$(2) $(LIBSYM) -D MSG_LEN=$(2)
endef

salsa20:
	@$(call compile_salsa20,salsa20,500)
	@$(call compile_salsa20,salsa20,1000)
	@$(call compile_salsa20,salsa20,1500)
	@$(call compile_salsa20,salsa20,2000)
	@$(call compile_salsa20,salsa20,2500)
	@$(call compile_salsa20,salsa20,3000)


# SHA256
SHA256_LIBS = sodium/utils.c																			\
                   randombytes/sysrandom/randombytes_sysrandom.c	\
                   randombytes/randombytes.c											\
                   crypto_hash/sha256/cp/hash_sha256.c

define compile_sha256
	gcc $(CFLAGS) $(patsubst %,$(LIBDIR)/%,$(SHA256_LIBS)) $(1)_wrapper.c -o $(1)_$(2) $(LIBSYM) -D MSG_LEN=$(2)
endef

sha256:
	@$(call compile_sha256,sha256,500)
	@$(call compile_sha256,sha256,1000)
	@$(call compile_sha256,sha256,1500)
	@$(call compile_sha256,sha256,2000)
	@$(call compile_sha256,sha256,2500)
	@$(call compile_sha256,sha256,3000)


# SHA512
SHA512_LIBS = sodium/utils.c																			\
                   randombytes/sysrandom/randombytes_sysrandom.c	\
                   randombytes/randombytes.c											\
                   crypto_hash/sha512/cp/hash_sha512.c

define compile_sha512
	gcc $(CFLAGS) $(patsubst %,$(LIBDIR)/%,$(SHA512_LIBS)) $(1)_wrapper.c -o $(1)_$(2) $(LIBSYM) -D MSG_LEN=$(2)
endef

sha512:
	@$(call compile_sha512,sha512,500)
	@$(call compile_sha512,sha512,1000)
	@$(call compile_sha512,sha512,1500)
	@$(call compile_sha512,sha512,2000)
	@$(call compile_sha512,sha512,2500)
	@$(call compile_sha512,sha512,3000)

clean:
	rm -rf *.o *.csv *.out smtdir/*/*.smt2
	rmdir smtdir/binsec_relse smtdir/binsec_sse
