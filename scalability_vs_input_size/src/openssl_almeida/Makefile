CLFLAGS=-m32 -g -static -Wall -O3
CFLAGS=$(CLFLAGS) -fno-stack-protector
LIB=-L../../../__libsym__/ -lsym


.PHONY: tls1_cbc_remove_padding_patch

all: tls1_cbc_remove_padding_patch

define compile
	gcc $(CFLAGS) $(1)_wrapper.c -o $(1)_$(2) $(LIB) -D LEN=$(2)
endef

tls1_cbc_remove_padding_patch:
	@$(call compile,tls1_cbc_remove_padding_patch,64)
	@$(call compile,tls1_cbc_remove_padding_patch,128)
	@$(call compile,tls1_cbc_remove_padding_patch,192)
	@$(call compile,tls1_cbc_remove_padding_patch,256)
	@$(call compile,tls1_cbc_remove_padding_patch,320)
	@$(call compile,tls1_cbc_remove_padding_patch,384)

clean:
	rm -rf *.o *.csv *.out smtdir/*/*.
