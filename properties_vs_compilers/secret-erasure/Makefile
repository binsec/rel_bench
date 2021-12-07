# x86 configuration
CFLAGSx86=-Wall -m32 -march=i386 -fno-stack-protector -static -fno-pic -fno-pie

# ARM configuration
CFLAGSARM=-Wall -march=armv7-a -static

NAME=secret-erasure

# Environement variable, set the version of the compiler
CC_VERSION?="unk"
CC_NAME=$(CC)_$(CC_VERSION)
OPT_VERSION?="opt"

ifeq ($(CC), armv7l-unknown-linux-gnueabihf-gcc)
	CFLAGS=$(CFLAGSARM)
else
	CFLAGS=$(CFLAGSx86)
endif

# Ugly fix because explicit bzero is not working with gcc_6.2.0
ifeq ($(CC_NAME), gcc_6.2.0)
	Suffix=-explicit-bzero-gcc-6
endif


# Choose version of safeclib
LIB=-L./safeclib_bin/$(CC_NAME) -lsafec-3.6.0 -L../__libsym__/ -lsym


.PHONY: all test loop memset memset_s bzero explicit_bzero weak_symbols			\
        weak_symbols_barrier memory_barrier_simple memory_barrier_ptr			\
        memory_barrier_mfence memory_barrier_lock volatile_ptr_loop				\
        volatile_ptr_memset ptr_to_volatile_loop vol_ptr_to_vol_loop			\
        vol_ptr_to_vol_memset ptr_to_volatile_memset volatile_func loop-no-dse	\
        memset-no-dse memset_s-no-dse bzero-no-dse explicit_bzero-no-dse		\
        weak_symbols-no-dse weak_symbols_barrier-no-dse							\
        memory_barrier_simple-no-dse memory_barrier_ptr-no-dse					\
        memory_barrier_mfence-no-dse memory_barrier_lock-no-dse					\
        volatile_ptr_loop-no-dse volatile_ptr_memset-no-dse						\
        ptr_to_volatile_loop-no-dse vol_ptr_to_vol_loop-no-dse					\
        vol_ptr_to_vol_memset-no-dse ptr_to_volatile_memset-no-dse				\
        volatile_func-no-dse

all: loop memset memset_s bzero explicit_bzero weak_symbols weak_symbols_barrier \
     memory_barrier_simple memory_barrier_ptr memory_barrier_mfence \
     memory_barrier_lock volatile_ptr_loop volatile_ptr_memset ptr_to_volatile_loop \
     vol_ptr_to_vol_loop vol_ptr_to_vol_memset ptr_to_volatile_memset volatile_func

all-no-dse: loop-no-dse memset-no-dse memset_s-no-dse bzero-no-dse			\
     explicit_bzero-no-dse weak_symbols-no-dse weak_symbols_barrier-no-dse	\
     memory_barrier_simple-no-dse memory_barrier_ptr-no-dse					\
     memory_barrier_mfence-no-dse memory_barrier_lock-no-dse				\
     volatile_ptr_loop-no-dse volatile_ptr_memset-no-dse					\
     ptr_to_volatile_loop-no-dse vol_ptr_to_vol_loop-no-dse					\
     vol_ptr_to_vol_memset-no-dse ptr_to_volatile_memset-no-dse				\
     volatile_func-no-dse

define compile
	echo " Compiling $(1) for -O0, -O1, -O2, -O3"
	$(CC) $(CFLAGS) -D $(1) $(NAME).c -O0 -o ./bin/$(NAME)_$(1)_O0_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) -D $(1) $(NAME).c -O1 -o ./bin/$(NAME)_$(1)_O1_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) -D $(1) $(NAME).c -O2 -o ./bin/$(NAME)_$(1)_O2_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) -D $(1) $(NAME).c -O3 -o ./bin/$(NAME)_$(1)_O3_$(CC_NAME) $(LIB)
# $(CC) $(CFLAGS) -D $(1) $(NAME).c -Ofast -o ./bin/$(NAME)_$(1)_Of_$(CC_NAME) $(LIB)
endef

# TODO -mllvm -x86-cmov-converter=false
# Selectively disable -dse
define compile-no-dse-clang
	echo "Compiling $(1) with clang and selectively disable -dse"
	$(CC) $(CFLAGS) -D $(1) -O3 -emit-llvm -Xclang -disable-llvm-passes -S $(NAME).c
	$(OPT_VERSION) -march=i386 $(OPT) -dse $(NAME).ll --filetype=asm -o $(NAME).bc
	$(CC) $(CFLAGS) $(NAME).bc -o ./bin/$(NAME)_$(1)_witnessO3_$(CC_NAME) $(LIB)
	rm $(NAME).bc $(NAME).ll
#
	$(CC) $(CFLAGS) -D $(1) -O3 -emit-llvm -Xclang -disable-llvm-passes -S $(NAME).c
	$(OPT_VERSION) -march=i386 $(OPT) $(NAME).ll --filetype=asm -o $(NAME).bc
	$(CC) $(CFLAGS) $(NAME).bc -o ./bin/$(NAME)_$(1)_no-dse_$(CC_NAME) $(LIB)
	rm $(NAME).bc $(NAME).ll
endef

# Selectively disable -dse -ftree-dse
define compile-no-dse-gcc
	echo "Compiling $(1) with gcc and selectively disable -dse -ftree-dse"
	$(CC) $(CFLAGS) -D $(1) -O3 $(NAME).c -o ./bin/$(NAME)_$(1)_witnessO3_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) -D $(1) -O3 -fno-dse $(NAME).c -o ./bin/$(NAME)_$(1)_no-dse_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) -D $(1) -O3 -fno-tree-dse $(NAME).c -o ./bin/$(NAME)_$(1)_no-tree-dse_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) -D $(1) -O3 -fno-dse -fno-tree-dse $(NAME).c -o ./bin/$(NAME)_$(1)_no-dse-all_$(CC_NAME) $(LIB)
endef

# For some reason the linker cannot find the function explicit-bzero so I use
# another linker
define compile-explicit-bzero-gcc-6
	echo " Compiling explicit-bzero-gcc-6 for -O0, -O1, -O2, -O3"
	$(CC) -c $(CFLAGS) -D EXPLICIT_BZERO $(NAME).c -O0 -o ./bin/$(NAME)_EXPLICIT_BZERO_O0_$(CC_NAME).o $(LIB)
	$(CC) -c $(CFLAGS) -D EXPLICIT_BZERO $(NAME).c -O1 -o ./bin/$(NAME)_EXPLICIT_BZERO_O1_$(CC_NAME).o $(LIB)
	$(CC) -c $(CFLAGS) -D EXPLICIT_BZERO $(NAME).c -O2 -o ./bin/$(NAME)_EXPLICIT_BZERO_O2_$(CC_NAME).o $(LIB)
	$(CC) -c $(CFLAGS) -D EXPLICIT_BZERO $(NAME).c -O3 -o ./bin/$(NAME)_EXPLICIT_BZERO_O3_$(CC_NAME).o $(LIB)
# $(CC) $(CFLAGS) -D EXPLICIT_BZERO $(NAME).c -Ofast -o ./bin/$(NAME)_EXPLICIT_BZERO_Of_$(CC_NAME) $(LIB)
endef


# For some reason the linker cannot find the function explicit-bzero so I use
# another linker
define compile-no-dse-gcc-explicit-bzero-gcc-6
	echo "Compiling $(1) with gcc and selectively disable -dse -ftree-dse"
	$(CC) -c $(CFLAGS) -D EXPLICIT_BZERO -O3 $(NAME).c -o ./bin/$(NAME)_EXPLICIT_BZERO_witnessO3_$(CC_NAME).o $(LIB)
	$(CC) -c $(CFLAGS) -D EXPLICIT_BZERO -O3 -fno-dse $(NAME).c -o ./bin/$(NAME)_EXPLICIT_BZERO_no-dse_$(CC_NAME).o $(LIB)
	$(CC) -c $(CFLAGS) -D EXPLICIT_BZERO -O3 -fno-tree-dse $(NAME).c -o ./bin/$(NAME)_EXPLICIT_BZERO_no-tree-dse_$(CC_NAME).o $(LIB)
	$(CC) -c $(CFLAGS) -D EXPLICIT_BZERO -O3 -fno-dse -fno-tree-dse $(NAME).c -o ./bin/$(NAME)_EXPLICIT_BZERO_no-dse-all_$(CC_NAME).o $(LIB)
endef


ifeq ($(CC), gcc)
	compile-no-dse=compile-no-dse-gcc
else
	compile-no-dse=compile-no-dse-clang
endif

loop:
	$(call compile,LOOP)
loop-no-dse:
	$(call $(compile-no-dse),LOOP)

memset:
	$(call compile,MEMSET)
memset-no-dse:
	$(call $(compile-no-dse),MEMSET)

memset_s:
	$(call compile,MEMSET_S)
memset_s-no-dse:
	$(call $(compile-no-dse),MEMSET_S)

bzero:
	$(call compile,BZERO)
bzero-no-dse:
	$(call $(compile-no-dse),BZERO)

explicit_bzero:
	$(call compile$(Suffix),EXPLICIT_BZERO)
explicit_bzero-no-dse:
	$(call $(compile-no-dse)$(Suffix),EXPLICIT_BZERO)

weak_symbols:
	$(call compile,WEAK_SYMBOLS)
weak_symbols-no-dse:
	$(call $(compile-no-dse),WEAK_SYMBOLS)

weak_symbols_barrier:
	$(call compile,WEAK_SYMBOLS_BARRIER)
weak_symbols_barrier-no-dse:
	$(call $(compile-no-dse),WEAK_SYMBOLS_BARRIER)

memory_barrier_simple:
	$(call compile,MEMORY_BARRIER_SIMPLE)
memory_barrier_simple-no-dse:
	$(call $(compile-no-dse),MEMORY_BARRIER_SIMPLE)

memory_barrier_ptr:
	$(call compile,MEMORY_BARRIER_PTR)
memory_barrier_ptr-no-dse:
	$(call $(compile-no-dse),MEMORY_BARRIER_PTR)

memory_barrier_mfence:
	$(call compile,MEMORY_BARRIER_MFENCE)
memory_barrier_mfence-no-dse:
	$(call $(compile-no-dse),MEMORY_BARRIER_MFENCE)

memory_barrier_lock:
	$(call compile,MEMORY_BARRIER_LOCK)
memory_barrier_lock-no-dse:
	$(call $(compile-no-dse),MEMORY_BARRIER_LOCK)

volatile_ptr_loop:
	$(call compile,VOLATILE_PTR_LOOP)
volatile_ptr_loop-no-dse:
	$(call $(compile-no-dse),VOLATILE_PTR_LOOP)

volatile_ptr_memset:
	$(call compile,VOLATILE_PTR_MEMSET)
volatile_ptr_memset-no-dse:
	$(call $(compile-no-dse),VOLATILE_PTR_MEMSET)

ptr_to_volatile_loop:
	$(call compile,PTR_TO_VOLATILE_LOOP)
ptr_to_volatile_loop-no-dse:
	$(call $(compile-no-dse),PTR_TO_VOLATILE_LOOP)

vol_ptr_to_vol_loop:
	$(call compile,VOL_PTR_TO_VOL_LOOP)
vol_ptr_to_vol_loop-no-dse:
	$(call $(compile-no-dse),VOL_PTR_TO_VOL_LOOP)

vol_ptr_to_vol_memset:
	$(call compile,VOL_PTR_TO_VOL_MEMSET)
vol_ptr_to_vol_memset-no-dse:
	$(call $(compile-no-dse),VOL_PTR_TO_VOL_MEMSET)

ptr_to_volatile_memset:
	$(call compile,PTR_TO_VOLATILE_MEMSET)
ptr_to_volatile_memset-no-dse:
	$(call $(compile-no-dse),PTR_TO_VOLATILE_MEMSET)

volatile_func:
	$(call compile,VOLATILE_FUNC)
volatile_func-no-dse:
	$(call $(compile-no-dse),VOLATILE_FUNC)

clean:
	rm -rf *.o *.csv

mrproper: clean
	rm ./bin/*
# find ./bin -type f -executable -name "secret-erasure*" -exec rm {} +
