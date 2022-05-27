CFLAGS=-m32 -march=i386 -DKRML_NOUINT128 -Wall
LIB=-L../../__libsym__/ -lsym
LOG="./log"
DEPS=Hacl_Policies.c

.PHONY: all clean
all: cmp_bytes rotate32_left rotate32_right \
	uint8_eq_mask uint8_gte_mask uint16_eq_mask uint16_gte_mask \
	uint32_eq_mask uint32_gte_mask uint64_eq_mask uint64_gte_mask


define compile
	echo "-------------------"
	echo " Compiling $(1)"
	echo "-------------------"
	gcc-5 -fno-stack-protector $(CFLAGS) -O0 $(DEPS) $(1).c -o $(1)_gcc5_O0 $(LIB)
	gcc-5 -fno-stack-protector $(CFLAGS) -O3 $(DEPS) $(1).c -o $(1)_gcc5_O3 $(LIB)
	gcc-8 -fno-stack-protector $(CFLAGS) -O0 $(DEPS) $(1).c -o $(1)_gcc8_O0 $(LIB)
	gcc-8 -fno-stack-protector $(CFLAGS) -O3 $(DEPS) $(1).c -o $(1)_gcc8_O3 $(LIB)
	clang-3.9 $(CFLAGS) -O0 $(DEPS) $(1).c -o $(1)_cl39_O0 $(LIB)
	clang-3.9 $(CFLAGS) -O3 $(DEPS) $(1).c -o $(1)_cl39_O3 $(LIB)
	clang-3.0 $(CFLAGS) -O0 $(DEPS) $(1).c -o $(1)_cl30_O0 $(LIB)
	clang-3.0 $(CFLAGS) -O3 $(DEPS) $(1).c -o $(1)_cl30_O3 $(LIB)
	clang-7 $(CFLAGS) -O0 $(DEPS) $(1).c -o $(1)_cl7_O0 $(LIB)
	clang-7 $(CFLAGS) -O3 $(DEPS) $(1).c -o $(1)_cl7_O3 $(LIB)
endef

define test
	@echo -n "$(1): "
	@mkdir -p $(LOG)
	@mkdir -p /tmp/SMTDIR/trace/; rm -R /tmp/SMTDIR/; mkdir -p /tmp/SMTDIR/trace/
	$(eval PARAMS := -relse -relse-dedup 1 -relse-fp instr \
	-fml-solver-timeout 0 -relse-timeout 3600 -sse-depth 100000 \
	-relse-paths 50 -sse-memory memory.txt -sse-load-ro-sections \
	-sse-load-sections .got.plt,.data,.plt -fml-solver boolector \
	-relse-store-type sha -relse-memory-type row-map 	\
	-sse-address-trace-file /tmp/SMTDIR/trace/ -sse-smt-dir \
	/tmp/SMTDIR/ -sse-comment  -relse-print-model \
	$(1))
	@echo "binsec $(PARAMS)" > $(LOG)/$(1)
	binsec $(PARAMS) >> $(LOG)/$(1) 2>&1 && \
	([ $$? -eq 0 ] && echo "PASS") || echo "FAIL!"
endef

define full_test
	@echo "-------------------"
	@echo " Testing $(1)"
	@echo "-------------------"
	$(call test,$(1)_"gcc5_O0")
	$(call test,$(1)_"gcc5_O3")
	$(call test,$(1)_"gcc8_O0")
	$(call test,$(1)_"gcc8_O3")
	$(call test,$(1)_"cl30_O0")
	$(call test,$(1)_"cl30_O3")
	$(call test,$(1)_"cl39_O0")
	$(call test,$(1)_"cl39_O3")
	$(call test,$(1)_"cl7_O0")
	$(call test,$(1)_"cl7_O3")
endef

cmp_bytes:
	@$(call compile,$@)
	@$(call full_test,$@)

rotate32_left:
	@$(call compile,$@)
	@$(call full_test,$@)

rotate32_right:
	@$(call compile,$@)
	@$(call full_test,$@)

uint8_eq_mask:
	@$(call compile,$@)
	@$(call full_test,$@)

uint8_gte_mask:
	@$(call compile,$@)
	@$(call full_test,$@)

uint16_eq_mask:
	@$(call compile,$@)
	@$(call full_test,$@)

uint16_gte_mask:
	@$(call compile,$@)
	@$(call full_test,$@)

uint32_eq_mask:
	@$(call compile,$@)
	@$(call full_test,$@)

uint32_gte_mask:
	@$(call compile,$@)
	@$(call full_test,$@)

uint64_eq_mask:
	@$(call compile,$@)
	@$(call full_test,$@)

uint64_gte_mask:
	@$(call compile,$@)
	@$(call full_test,$@)

analysis:
	@$(call full_test,cmp_bytes)
	@$(call full_test,rotate32_left)
	@$(call full_test,rotate32_right)
	@$(call full_test,uint8_eq_mask)
	@$(call full_test,uint8_gte_mask)
	@$(call full_test,uint16_eq_mask)
	@$(call full_test,uint16_gte_mask)
	@$(call full_test,uint32_eq_mask)
	@$(call full_test,uint32_gte_mask)
	@$(call full_test,uint64_eq_mask)
	@$(call full_test,uint64_gte_mask)

clean:
	rm -rf *.o *.csv *.out

mrproper: clean
	find . -type f -executable | xargs rm
