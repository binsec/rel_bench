CFLAGS=-Wall -m32 -g -fno-stack-protector
LIB=-L../../__libsym__/ -lsym

.PHONY: all clean loop_secure_O0 loop_insecure_O0 conditional_insecure_O0 conditional_secure_O0 function_call_insecure_O0 function_call_secure_O0 function_return_insecure_O0 function_return_secure_O0 memory_access_insecure_O0 memory_access_secure_O0 double_insecure_O0


all: loop_secure_O0 loop_insecure_O0 conditional_insecure_O0 conditional_secure_O0 function_call_insecure_O0 function_call_secure_O0 function_return_insecure_O0 function_return_secure_O0 memory_access_insecure_O0 memory_access_secure_O0 double_insecure_O0

loop_secure_O0:
	gcc $(CFLAGS) -O0 loop_secure.c -o $@ $(LIB)

loop_insecure_O0:
	gcc $(CFLAGS) -O0 loop_insecure.c -o $@ $(LIB)

conditional_insecure_O0:
	gcc $(CFLAGS) -O0 conditional_insecure.c -o $@ $(LIB)

conditional_secure_O0:
	gcc $(CFLAGS) -O0 conditional_secure.c -o $@ $(LIB)

function_call_insecure_O0:
	gcc $(CFLAGS) -O0 function_call_insecure.c -o $@ $(LIB)

function_call_secure_O0:
	gcc $(CFLAGS) -O0 function_call_secure.c -o $@ $(LIB)

function_return_insecure_O0:
	gcc $(CFLAGS) -O0 function_return_insecure.c -o $@ $(LIB)

function_return_secure_O0:
	gcc $(CFLAGS) -O0 function_return_secure.c -o $@ $(LIB)

memory_access_insecure_O0:
	gcc $(CFLAGS) -O0 memory_access_insecure.c -o $@ $(LIB)

memory_access_secure_O0:
	gcc $(CFLAGS) -O0 memory_access_secure.c -o $@ $(LIB)

double_insecure_O0:
	gcc $(CFLAGS) -O0 double_insecure.c -o $@ $(LIB)

clean:
	rm -rf *.o *.csv *.out smtdir/*/*.smt2

mrproper: clean
	find . -type f -executable | xargs rm
