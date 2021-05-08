CFLAGS=-m32 -g -fno-stack-protector -static -DKRML_NOUINT128 -Wall
LIB=-L../../__libsym__/ -lsym
LIBHACL= -I./hacl-c/hacl-c/ -L./hacl-c/hacl-c/ -lhacl32

.PHONY: all chacha20 curve25519 sha256 sha512 cmp_bytes
all: all chacha20 curve25519 sha256 sha512 cmp_bytes

chacha20:
	gcc $(CFLAGS) $@_wrapper.c -o $@  $(LIB) $(LIBHACL)

curve25519:
	gcc $(CFLAGS) $@_wrapper.c -o $@  $(LIB) $(LIBHACL)

sha256:
	gcc $(CFLAGS) $@_wrapper.c -o $@  $(LIB) $(LIBHACL)

sha512:
	gcc $(CFLAGS) $@_wrapper.c -o $@  $(LIB) $(LIBHACL)

cmp_bytes:
	gcc $(CFLAGS) $@_wrapper.c -o $@  $(LIB) $(LIBHACL)

clean:
	rm -rf *.o *.csv *.out smtdir/*/*.smt2

mrproper: clean
	find . -type f -executable | xargs rm
