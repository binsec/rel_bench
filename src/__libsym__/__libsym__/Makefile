CFLAGS=-Wall -m32 -g -fno-stack-protector -static

.PHONY: all libsym.a

all:libsym.a

sym.o:
	gcc -c $(CFLAGS) sym.c

libsym.a: sym.o
	ar rcs libsym.a sym.o
	rm sym.o

clean:
	rm libsym.a sym.o *~
