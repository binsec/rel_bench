CFLAGS=-m32 -march=i386
LIB=-L../__libsym__/ -lsym
LOG="./log"

.PHONY: all clean
all: ct_eq_8 ct_eq_int ct_is_zero_8 ct_lt ct_select ct_eq ct_ge_8 ct_is_zero ct_msb ct_eq_int_8 ct_ge ct_lt_8 ct_select_8

define compile
	echo "-------------------"
	echo " Compiling $(1)"
	echo "-------------------"
	gcc-5 -fno-stack-protector $(CFLAGS) -O0  $(1).c -o $(1)_gcc5_O0 $(LIB)
	gcc-5 -fno-stack-protector $(CFLAGS) -O3  $(1).c -o $(1)_gcc5_O3 $(LIB)
	gcc-8 -fno-stack-protector $(CFLAGS) -O0  $(1).c -o $(1)_gcc8_O0 $(LIB)
	gcc-8 -fno-stack-protector $(CFLAGS) -O3  $(1).c -o $(1)_gcc8_O3 $(LIB)
	clang-3.9 $(CFLAGS) -O0  $(1).c -o $(1)_cl39_O0 $(LIB)
	clang-3.9 $(CFLAGS) -O3  $(1).c -o $(1)_cl39_O3 $(LIB)
	clang-3.0 $(CFLAGS) -O0  $(1).c -o $(1)_cl30_O0 $(LIB)
	clang-3.0 $(CFLAGS) -O3  $(1).c -o $(1)_cl30_O3 $(LIB)
	clang-7 $(CFLAGS) -O0  $(1).c -o $(1)_cl7_O0 $(LIB)
	clang-7 $(CFLAGS) -O3  $(1).c -o $(1)_cl7_O3 $(LIB)
endef

define test
	@echo -n "$(1): "
	@mkdir -p $(LOG)
	@mkdir -p /tmp/SMTDIR/trace/; rm -R /tmp/SMTDIR/; mkdir -p /tmp/SMTDIR/trace/
	$(eval PARAMS := -relse -relse-dedup 1 -relse-fp instr \
	-fml-solver-timeout 0 -relse-timeout 3600 -sse-depth 10000 \
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

ct_eq_8:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_ge_8:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_msb:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_eq:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_ge:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_lt_8:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_select_8:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_eq_int_8:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_is_zero_8:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_lt:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_select:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_eq_int:
	@$(call compile,$@)
	@$(call full_test,$@)

ct_is_zero:
	@$(call compile,$@)
	@$(call full_test,$@)

analyze:
	@$(call full_test,ct_eq_8);
	@$(call full_test,ct_eq_int);
	@$(call full_test,ct_is_zero_8);
	@$(call full_test,ct_lt);
	@$(call full_test,ct_select);
	@$(call full_test,ct_eq);
	@$(call full_test,ct_ge_8);
	@$(call full_test,ct_is_zero);
	@$(call full_test,ct_msb);
	@$(call full_test,ct_eq_int_8);
	@$(call full_test,ct_ge);
	@$(call full_test,ct_lt_8);
	@$(call full_test,ct_select_8);


clean:
	rm -rf *.o *.csv *.out

mrproper: clean
	find . -type f -executable | xargs rm
