# x86 configuration
CFLAGSx86=-m32 -march=i386 -fno-stack-protector
CFLAGSARM=-march=armv7-a -static -fno-stack-protector
ARM_CC=arm-linux-gnueabi-gcc
# Environement variable, set the version of the compiler
CC_VERSION?=unk
CC_NAME=$(CC)_$(CC_VERSION)


ifeq ($(CC), $(ARM_CC))
	CFLAGS=$(CFLAGSARM)
else
	CFLAGS=$(CFLAGSx86)
endif
LIB=-L./src/__libsym__/ -lsym
LIB_ARM=-L./src/__libsym__/ -lsym_arm


.PHONY:

all: ct_select_all ct_sort_all tea_all openssl_utility_all hacl_utility_all
ct_select_all: ct_select_v1 ct_select_v2 ct_select_v3 ct_select_v4 naive_select
ct_sort_all: sort sort_multiplex sort_negative
tea_all: tea_encrypt tea_decrypt
openssl_utility_all: ct_eq_8 ct_eq_int ct_is_zero_8 ct_lt ct_select ct_eq	\
	ct_ge_8 ct_is_zero ct_msb ct_eq_int_8 ct_ge ct_lt_8 ct_select_8
hacl_utility_all: cmp_bytes rotate32_left rotate32_right uint8_eq_mask	\
	uint8_gte_mask uint16_eq_mask uint16_gte_mask uint32_eq_mask		\
	uint32_gte_mask uint64_eq_mask uint64_gte_mask


# Directory / Bench label / C program(s) to compile
define compile-gcc
	echo " Compiling $(2)"
	$(CC) $(CFLAGS) $(3) -O0 -fno-if-conversion -fno-if-conversion2 -fno-tree-loop-if-convert -o ./bin/$(1)/$(2)_O0_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O0 -fif-conversion -fif-conversion2 -ftree-loop-if-convert -o ./bin/$(1)/$(2)_O0-cmov_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O1 -o ./bin/$(1)/$(2)_O1_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O2 -o ./bin/$(1)/$(2)_O2_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O3 -fif-conversion -fif-conversion2 -ftree-loop-if-convert -o ./bin/$(1)/$(2)_O3_$(CC_NAME) $(LIB)
# $(CC) $(CFLAGS) $(3) -Ofast -o ./bin/$(1)/$(2)_Of_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O3 -fno-if-conversion -fno-if-conversion2 -fno-tree-loop-if-convert -o ./bin/$(1)/$(2)_O3-cmov_$(CC_NAME) $(LIB)
endef

# Directory / Bench label / C program(s) to compile
define compile-clang
	echo " Compiling $(2)"
	$(CC) $(CFLAGS) $(3) -O0 -o ./bin/$(1)/$(2)_O0_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O1 -o ./bin/$(1)/$(2)_O1_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O2 -o ./bin/$(1)/$(2)_O2_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O3 -mllvm -x86-cmov-converter=1 -o ./bin/$(1)/$(2)_O3_$(CC_NAME) $(LIB)
# $(CC) $(CFLAGS) $(3) -Ofast -o ./bin/$(1)/$(2)_Of_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O3 -mllvm -x86-cmov-converter=0 -o ./bin/$(1)/$(2)_O3-cmov_$(CC_NAME) $(LIB)
endef

define compile-clang-old
	echo " Compiling $(2)"
	$(CC) $(CFLAGS) $(3) -O0 -o ./bin/$(1)/$(2)_O0_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O1 -o ./bin/$(1)/$(2)_O1_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O2 -o ./bin/$(1)/$(2)_O2_$(CC_NAME) $(LIB)
	$(CC) $(CFLAGS) $(3) -O3 -o ./bin/$(1)/$(2)_O3_$(CC_NAME) $(LIB)
# $(CC) $(CFLAGS) $(3) -Ofast -o ./bin/$(1)/$(2)_Of_$(CC_NAME) $(LIB)
endef

define compile-arm
	echo " Compiling $(2)"
	$(CC) $(CFLAGS) $(3) -O0 -o ./bin/$(1)/$(2)_O0_$(CC_NAME) $(LIB_ARM)
	$(CC) $(CFLAGS) $(3) -O0 -fif-conversion -fif-conversion2 -ftree-loop-if-convert -o ./bin/$(1)/$(2)_O0-cmov_$(CC_NAME) $(LIB_ARM)
	$(CC) $(CFLAGS) $(3) -O1 -o ./bin/$(1)/$(2)_O1_$(CC_NAME) $(LIB_ARM)
	$(CC) $(CFLAGS) $(3) -O2 -o ./bin/$(1)/$(2)_O2_$(CC_NAME) $(LIB_ARM)
	$(CC) $(CFLAGS) $(3) -O3 -fif-conversion -fif-conversion2 -ftree-loop-if-convert -o ./bin/$(1)/$(2)_O3_$(CC_NAME) $(LIB_ARM)
# $(CC) $(CFLAGS) $(3) -Ofast -o ./bin/$(1)/$(2)_Of_$(CC_NAME) $(LIB_ARM)
	$(CC) $(CFLAGS) $(3) -O3 -fno-if-conversion -fno-if-conversion2 -fno-tree-loop-if-convert -o ./bin/$(1)/$(2)_O3-cmov_$(CC_NAME) $(LIB_ARM)
endef

ifeq ($(CC), $(ARM_CC))
	compile=compile-arm
endif
ifeq ($(CC), clang-3.0)
	compile=compile-clang-old
endif
ifeq ($(CC), clang-3.9)
	compile=compile-clang-old
endif
ifeq ($(CC), gcc)
	compile=compile-gcc
endif
ifeq ($(CC), clang)
	compile=compile-clang
endif


ct_select_v1 ct_select_v2 ct_select_v3 ct_select_v4 naive_select:
	@$(call $(compile),ct-select,$@,./src/ct-select/$@.c ./src/ct-select/lib.c)

sort sort_multiplex sort_negative:
	@$(call $(compile),ct-sort,$@,./src/ct-sort/$@.c ./src/ct-sort/lib.c)

tea_encrypt tea_decrypt:
	@$(call $(compile),tea,$@,./src/tea/$@_wrapper.c ./src/tea/tea.c)

ct_eq_8 ct_eq_int ct_is_zero_8 ct_lt ct_select ct_eq ct_ge_8 ct_is_zero ct_msb ct_eq_int_8 ct_ge ct_lt_8 ct_select_8:
	@$(call $(compile),openssl_utility,$@,./src/openssl_utility/$@.c)

cmp_bytes rotate32_left rotate32_right uint8_eq_mask uint8_gte_mask uint16_eq_mask uint16_gte_mask uint32_eq_mask uint32_gte_mask uint64_eq_mask uint64_gte_mask:
	@$(call $(compile),hacl_utility,$@,./src/hacl_utility/$@.c ./src/hacl_utility/Hacl_Policies.c)

clean:
	rm -rf *.o *.csv

mrproper: clean
	rm ./bin/*
