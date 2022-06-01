CFLAGS=-m32 -g -fno-stack-protector -static -DKRML_NOUINT128 -Wall -O3 -fno-pie -fno-pic
LIB=-L../../../__libsym__/ -lsym
LIBHACL= -I./hacl-c/hacl-c/ -L./hacl-c/hacl-c/ -lhacl32

.PHONY: all chacha20 sha256 sha512
all: all chacha20 sha256 sha512

define compile
	gcc $(CFLAGS) $(1)_wrapper.c -o $(1)_$(2) $(LIB) $(LIBHACL) -D MESSAGE_LEN=$(2)
endef

chacha20:
	@$(call compile,chacha20,500)
	@$(call compile,chacha20,1000)
	@$(call compile,chacha20,1500)
	@$(call compile,chacha20,2000)
	@$(call compile,chacha20,2500)
	@$(call compile,chacha20,3000)

sha256:
	@$(call compile,sha256,500)
	@$(call compile,sha256,1000)
	@$(call compile,sha256,1500)
	@$(call compile,sha256,2000)
	@$(call compile,sha256,2500)
	@$(call compile,sha256,3000)

sha512:
	@$(call compile,sha512,500)
	@$(call compile,sha512,1000)
	@$(call compile,sha512,1500)
	@$(call compile,sha512,2000)
	@$(call compile,sha512,2500)
	@$(call compile,sha512,3000)

clean:
	rm -rf *.o *.csv *.out smtdir/*/*.smt2

mrproper: clean
	find . -type f -executable | xargs rm
