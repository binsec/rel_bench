CFLAGS=-m32 -march=i386 -DKRML_NOUINT128 -Wall -fno-stack-protector -fno-pie -fno-pic
LIB=-L../../../__libsym__/ -lsym
LOG="./log"
DEPS=Hacl_Policies.c

.PHONY: all clean
all: cmp_bytes


define compile
	echo "-------------------"
	echo " Compiling $(1)"
	echo "-------------------"
	gcc-10 -fno-stack-protector $(CFLAGS) -O0 $(DEPS) $(1).c -o $(1)_O0_$(2) $(LIB) -D LEN=$(2)
	gcc-10 -fno-stack-protector $(CFLAGS) -O3 $(DEPS) $(1).c -o $(1)_O3_$(2) $(LIB) -D LEN=$(2)
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
	binsec-rel $(PARAMS) >> $(LOG)/$(1) 2>&1 && \
	([ $$? -eq 0 ] && echo "PASS") || echo "FAIL!"
endef

define full_test
	@echo "-------------------"
	@echo " Testing $(1)"
	@echo "-------------------"
	$(call test,$(1)_"O0_200")
	$(call test,$(1)_"O3_200")
	$(call test,$(1)_"O0_400")
	$(call test,$(1)_"O3_400")
	$(call test,$(1)_"O0_600")
	$(call test,$(1)_"O3_600")
	$(call test,$(1)_"O0_800")
	$(call test,$(1)_"O3_800")
	$(call test,$(1)_"O0_1000")
	$(call test,$(1)_"O3_1000")
endef

cmp_bytes:
	@$(call compile,cmp_bytes,500)
	@$(call compile,cmp_bytes,1000)
	@$(call compile,cmp_bytes,1500)
	@$(call compile,cmp_bytes,2000)
	@$(call compile,cmp_bytes,2500)
	@$(call compile,cmp_bytes,3000)

analysis:
	@$(call full_test,cmp_bytes)

clean:
	rm -rf *.o *.csv *.out

mrproper: clean
	cmp_bytes_O0_* 	cmp_bytes_O3_*
