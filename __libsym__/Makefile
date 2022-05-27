CFLAGSx86=-Wall -m32 -fno-stack-protector -static
CFLAGSARM=-Wall -march=armv7-a -static

ifeq ($(CC), armv7l-unknown-linux-gnueabihf-gcc)
	CFLAGS=$(CFLAGSARM)
	ARCH=_arm
else
	CFLAGS=$(CFLAGSx86)
endif


.PHONY: all libsym.a

all:libsym.a

sym.o:
	$(CC) -c $(CFLAGS) sym.c

libsym.a: sym.o
	ar rcs libsym$(ARCH).a sym.o
	rm sym.o

clean:
	rm libsym.a libsym_arm.a sym.o *~
