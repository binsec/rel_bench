CFLAGSx86=-Wall -m32 -fno-stack-protector -static
CFLAGSARM=-Wall -march=armv7-a -static


.PHONY: all libsym.a

all:libsym.a

sym.o:
	$(CC) -c $(CFLAGSx86) sym.c

libsym.a: sym.o
	ar rcs libsym$(ARCH).a sym.o
	rm sym_arm.o

sym_arm.o:
	arm-linux-gnueabi-gcc -c $(CFLAGSARM) sym.c -o sym_arm.o

libsym_arm.a: sym_arm.o
	ar rcs libsym_arm.a sym.o
	rm sym_arm.o

clean:
	rm libsym.a libsym_arm.a sym.o *~
