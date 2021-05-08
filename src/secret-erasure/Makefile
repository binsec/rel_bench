# x86 configuration
CFLAGSx86=-Wall -m32 -march=i386 -fno-stack-protector -static -fno-pic

# ARM configuration
CFLAGSARM=-Wall -march=armv7-a -static

ifeq ($(CC), armv7l-unknown-linux-gnueabihf-gcc)
	CFLAGS=$(CFLAGSARM)
else
	CFLAGS=$(CFLAGSx86)
endif

NAME=secret-erasure

# Environement variable, set the version of the compiler
CC_VERSION?="unk"
CC_NAME=$(CC)_$(CC_VERSION)

# Choose version of safeclib
LIB=-L./safeclib_bin/$(CC_NAME) -lsafec-3.6.0 -L../__libsym__/ -lsym


.PHONY: all loop memset memset_s bzero explicit_bzero weak_symbols weak_symbols_barrier \
        memory_barrier_simple memory_barrier_ptr memory_barrier_mfence \
        memory_barrier_lock volatile_ptr_loop volatile_ptr_memset ptr_to_volatile_loop \
        vol_ptr_to_vol_loop vol_ptr_to_vol_memset ptr_to_volatile_memset volatile_func


all: loop memset memset_s bzero explicit_bzero weak_symbols weak_symbols_barrier \
     memory_barrier_simple memory_barrier_ptr memory_barrier_mfence \
     memory_barrier_lock volatile_ptr_loop volatile_ptr_memset ptr_to_volatile_loop \
     vol_ptr_to_vol_loop vol_ptr_to_vol_memset ptr_to_volatile_memset volatile_func

define compile
	echo " Compiling $(1) for -O0, -O1, -O2, -O3, -Ofast"
	$(CC) $(CFLAGS) -D $(1) $(NAME).c -O0 -o ./bin/$(NAME)_$(1)_O0_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) -D $(1) $(NAME).c -O1 -o ./bin/$(NAME)_$(1)_O1_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) -D $(1) $(NAME).c -O2 -o ./bin/$(NAME)_$(1)_O2_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) -D $(1) $(NAME).c -O3 -o ./bin/$(NAME)_$(1)_O3_$(CC_NAME) $(LIB)
# $(CC) $(CFLAGS) -D $(1) $(NAME).c -Ofast -o ./bin/$(NAME)_$(1)_Of_$(CC_NAME) $(LIB)
endef

loop:
	@$(call compile,LOOP)

memset:
	@$(call compile,MEMSET)

memset_s:
	@$(call compile,MEMSET_S)

bzero:
	@$(call compile,BZERO)

explicit_bzero:
	@$(call compile,EXPLICIT_BZERO)

weak_symbols:
	@$(call compile,WEAK_SYMBOLS)

weak_symbols_barrier:
	@$(call compile,WEAK_SYMBOLS_BARRIER)

memory_barrier_simple:
	@$(call compile,MEMORY_BARRIER_SIMPLE)

memory_barrier_ptr:
	@$(call compile,MEMORY_BARRIER_PTR)

memory_barrier_mfence:
	@$(call compile,MEMORY_BARRIER_MFENCE)

memory_barrier_lock:
	@$(call compile,MEMORY_BARRIER_LOCK)

volatile_ptr_loop:
	@$(call compile,VOLATILE_PTR_LOOP)

volatile_ptr_memset:
	@$(call compile,VOLATILE_PTR_MEMSET)

ptr_to_volatile_loop:
	@$(call compile,PTR_TO_VOLATILE_LOOP)

vol_ptr_to_vol_loop:
	@$(call compile,VOL_PTR_TO_VOL_LOOP)

vol_ptr_to_vol_memset:
	@$(call compile,VOL_PTR_TO_VOL_MEMSET)


ptr_to_volatile_memset:
	@$(call compile,PTR_TO_VOLATILE_MEMSET)

volatile_func:
	@$(call compile,VOLATILE_FUNC)

clean:
	rm -rf *.o *.csv

mrproper: clean
	rm ./bin/*
# find ./bin -type f -executable -name "secret-erasure*" -exec rm {} +
