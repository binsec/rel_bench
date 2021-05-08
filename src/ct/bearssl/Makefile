CFLAGS=-m32 -g -fno-stack-protector -static -Wall
LIB=-L../../__libsym__/ -lsym
LIBBEARSSL= -I./inc -L./. -lbearssl
WRAPPER=${NAME}_wrapper


.PHONY: aes_big aes_ct des_tab des_ct
all: aes_big aes_ct des_tab des_ct

aes_big:
	gcc $(CFLAGS) $@_wrapper.c -o $@  $(LIB) $(LIBBEARSSL)

aes_ct:
	gcc $(CFLAGS) $@_wrapper.c -o $@  $(LIB) $(LIBBEARSSL)

des_tab:
	gcc $(CFLAGS) $@_wrapper.c -o $@  $(LIB) $(LIBBEARSSL)

des_ct:
	gcc $(CFLAGS) $@_wrapper.c -o $@  $(LIB) $(LIBBEARSSL)

clean:
	rm -rf *.o *.csv *.out smtdir/*/*.smt2

mrproper: clean
	find . -type f -executable | xargs rm
