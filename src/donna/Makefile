CFLAGS=-Wall -m32 -g -fno-stack-protector -static
LIB=-L../../__libsym__/ -lsym
NAME=donna
WRAPPER=${NAME}_wrapper


.PHONY: all clean

all: donna_O0 donna_O1 donna_O2 donna_O3 donna_Of

%.c:
	gcc $(CFLAGS) $@.c -o $@

donna_O0:
	gcc $(CFLAGS) ${WRAPPER}.c -O0 -o $@  $(LIB)

donna_O1:
	gcc $(CFLAGS) ${WRAPPER}.c -O1 -o $@  $(LIB)

donna_O2:
	gcc $(CFLAGS) ${WRAPPER}.c -O2 -o $@  $(LIB)

donna_O3:
	gcc $(CFLAGS) ${WRAPPER}.c -O3 -o $@  $(LIB)

donna_Of:
	gcc $(CFLAGS) ${WRAPPER}.c -Ofast -o $@  $(LIB)

clean:
	rm -rf *.o *.csv *.out smtdir/*/*.smt2

mrproper: clean
	find . -type f -executable | xargs rm
